---
title: python实现中国象棋（四）
date: 2024-02-19 12:42:53
tags:
---



## UCCI协议简介

使用https://github.com/Vincentzyx/VinXiangQi，可以与天天象棋连线。将bot实现为UCCI协议的引擎，用来与该软件通信，从而接入天天象棋。

UCCI协议参考https://elapse.date/article/detail/30，这里实现以下指令：

> 　 电脑象棋联赛使用 UCCI 引擎，参赛引擎必须能够识别并正确处理以下的指令：
>
> - ucci；
> - position fen … [moves …]；
> - banmoves …；
> - go [draw] time … increment … [opptime … oppincrement …]；
> - quit。
>
> 参赛引擎必须能够反馈的信息有：
>
> - ucciok；
> - bestmove … [draw | resign]。

## 实现UCCI引擎

### 修正ChessBoard

由于UCCI协议中，红色可以在上方也可以在下方，所以象、士、将、兵的逻辑需要修改，不能假定红色在上方。

同时，增加了一个get_up_side函数，逻辑是判断上方九宫格里的将/帅是红还是黑。该函数方便了兵/卒逻辑的实现。

```python
    def _get_elephant_moves(self, row, col):
        possible_moves = []
        current_piece = self.board[row][col]
        directions = [(2, 2), (2, -2), (-2, 2), (-2, -2)]  # 定义“相”或“象”移动的四个方向

        for dr, dc in directions:
            new_row, new_col = row + dr, col + dc
            middle_row, middle_col = row + dr // 2, col + dc // 2  # 计算“田”字中心的位置
            # 检查目标位置和“田”字中心的位置是否合法
            if 0 <= new_row < 10 and 0 <= new_col < 9 and self.board[middle_row][middle_col] is None:
                # 确定当前位置和新位置是否在楚河汉界的同一侧
                if (row < 5 and new_row < 5) or (row >= 5 and new_row >= 5):
                    target_piece = self.board[new_row][new_col]
                    if target_piece is None or target_piece.side != current_piece.side:
                        possible_moves.append((new_row, new_col))

        return possible_moves
    
    def _get_guard_moves(self, row, col):
        moves = []
        directions = [(-1, -1), (-1, 1), (1, -1), (1, 1)]  # 斜线移动的四个方向
        # 两个九宫格的范围合并，无需区分红黑方
        palace_bounds = [((0, 2), (3, 5)), ((7, 9), (3, 5))]

        for drow, dcol in directions:
            new_row, new_col = row + drow, col + dcol
            # 检查是否在任一九宫格内
            in_palace = any(rb[0] <= new_row <= rb[1] and cb[0] <= new_col <= cb[1] for rb, cb in palace_bounds)
            if in_palace:
                target_piece = self.board[new_row][new_col]
                # 检查目标位置是否为空或有对方棋子
                if target_piece is None or target_piece.side != self.board[row][col].side:
                    moves.append((new_row, new_col))

        return moves
    
    def _get_king_moves(self, row, col):
        possible_moves = []
        current_piece = self.board[row][col]
        directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]  # 定义移动方向：上、下、左、右
        
        # 设置统一的九宫格范围，适用于所有棋子
        king_zone = [(0, 2, 3, 5), (7, 9, 3, 5)]  # 合并红黑方的九宫格范围

        for dr, dc in directions:
            new_row, new_col = row + dr, col + dc
            # 检查是否在任一九宫格内
            if any(zone[0] <= new_row <= zone[1] and zone[2] <= new_col <= zone[3] for zone in king_zone):
                target_piece = self.board[new_row][new_col]
                if target_piece is None or target_piece.side != current_piece.side:
                    possible_moves.append((new_row, new_col))

        # 检查垂直方向上是否直接对面对方的“将”或“帅”
        direction_to_check = 1 if current_piece.side == 'red' else -1
        for i in range(1, 10):  # 最多检查棋盘的高度
            check_row = row + i * direction_to_check
            if check_row < 0 or check_row > 9:
                break
            target_piece = self.board[check_row][col]
            if target_piece is not None:
                if target_piece.name in ['帅', '将'] and target_piece.side != current_piece.side:
                    possible_moves.append((check_row, col))
                break

        return possible_moves
    
   def _get_pawn_moves(self, row, col):
        possible_moves = []
        current_piece = self.board[row][col]
        move_direction = 1 if current_piece.side == self.get_up_side() else -1

        
        # 前进一步的移动
        forward_row = row + move_direction
        if 0 <= forward_row < 10:
            if self.board[forward_row][col] is None or self.board[forward_row][col].side != current_piece.side:
                possible_moves.append((forward_row, col))

        # 楚河汉界后的左右移动
        if (move_direction == 1 and row >= 5) or (move_direction == -1 and row < 5):
            for side_step in [-1, 1]:  # 左移和右移
                side_col = col + side_step
                if 0 <= side_col < 9:
                    if self.board[row][side_col] is None or self.board[row][side_col].side != current_piece.side:
                        possible_moves.append((row, side_col))

        return possible_moves
    
    
    def get_up_side(self) -> str:
        """ 获取上方的颜色。

        Returns:
            str: 上方的颜色，"black" 或 "red"。
        """
        if self._up_side is not None:
            return self._up_side

        for row in range(0, 3):
            for col in range(3, 6):
                piece = self.board[row][col]
                if piece and piece.name in ['将', '帅']:
                    self._up_side = piece.side
                    return self._up_side

        # 如果上方九宫格中没有“将”或“帅”，则返回None或抛出异常
        return None
```

### 实现ucci.py

```python
from typing import Optional
from ChessBoard import ChessBoard, ChessPiece
from AlphaBetaBot import AlphaBetaBot

class UcciEngine:
    def __init__(self) -> None:
        self.board = ChessBoard()
        self.bot = AlphaBetaBot(self.board, "red", 3)

    def parse_ucci_command(self, command: str) -> None:
        if command == "ucci":
            self.handle_ucci()
        elif command.startswith("position fen"):
            fen = command[len("position fen "):].strip()
            self.handle_position_fen(fen)
        elif command.startswith("go"):
            self.handle_go(command)
        elif command == "quit":
            self.handle_quit()
        else:
            print("Unknown command")

    def handle_ucci(self) -> None:
        print("ucciok")

    def handle_position_fen(self, fen: str) -> None:
        # 这里假设ChessBoard类有一个方法load_from_fen来处理FEN字符串
        self.board.load_from_fen(fen)
        # self.board.print_board()
        self.bot.side = "red" if fen.split()[1] == "w" else "black"
        print("position set")

    def handle_go(self, command: str) -> None:
        # 解析时间参数并根据这些参数启动搜索算法
        best_move = self.bot.make_move()
        # coords like ((0,1), (2,3)) to str like "e1e2": 
        best_move_str = "".join([chr(y + ord('a')) + str(x) for x, y in best_move])
        print("bestmove", best_move_str)

    def handle_quit(self) -> None:
        import sys
        sys.exit(0)

    def run(self) -> None:
        while True:
            command = input()
            self.parse_ucci_command(command)

if __name__ == "__main__":
    engine = UcciEngine()
    engine.run()

```

这样就实现了一个简单的ucci引擎。

编写一个C程序，用system函数执行该脚本，将C程序编译成exe，就可以将这个ucci引擎导入上述**VIN象棋**工具。

与天天象棋的最低级别AI对弈，经常因循环走子而判负。与第三级AI对弈无法获胜。棋力仍然较弱。

