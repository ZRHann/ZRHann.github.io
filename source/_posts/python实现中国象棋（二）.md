---
title: python实现中国象棋（二）
date: 2024-02-17 22:07:01
tags:
typora-root-url: ..
---





### 实现随机落子的RandomBot

该bot只是从所有可能的落子方式中随机选取一种。

#### 增加几个工具方法

```python
    def get_possible_moves_with_coords(self, position: tuple) -> list:
        """根据行列坐标获取指定位置的棋子的可能移动位置。该函数是 get_possible_moves 方法的包装。

        Args:
            position (tuple): 棋子的行列坐标，例如 (0, 0)。

        Returns:
            _type_: 可能移动位置的列表，每个位置为 (row, col) 形式的元组。
        """
        position_str = self.coords_to_alphanumeric([position])[0]
        return self.get_possible_moves(position_str)

    def move_piece_with_coords(self, src_coords: tuple, dest_coords: tuple) -> bool:
        """根据行列坐标移动棋子。该函数是 move_piece 方法的包装。
            Args:
                src_coords (tuple): 源位置的行列坐标，例如 (0, 0)。
                dest_coords (tuple): 目标位置的行列坐标，例如 (0, 1)。
            Returns:
                bool: 移动是否成功。
        """
        src_str = self.coords_to_alphanumeric([src_coords])[0]
        dest_str = self.coords_to_alphanumeric([dest_coords])[0]
        return self.move_piece(src_str, dest_str)

    def get_pieces_positions(self, side: str) -> list:
        """获取指定颜色方的所有棋子的坐标。

        Args:
            side (str): 棋子的颜色，"black" 或 "red"。

        Returns:
            list: 该颜色方的所有棋子的坐标元组列表，每个元组为(row, col)。
        """
        positions = []
        len_row = len(self.board)
        len_col = len(self.board[0])
        for row in range(len_row):
            for col in range(len_col):
                piece = self.board[row][col]
                if piece is not None and piece.side == side:
                    positions.append((row, col))
        return positions
```

#### 实现RandomBot.py

其中，ChessBoard和ChessPiece类放到了ChessBoard.py

```python
import random
from ChessBoard import ChessBoard

class RandomBot:
    def __init__(self, chessboard: ChessBoard, side: str):
        self.chessboard = chessboard
        self.side = side

    def make_random_move(self):
        pieces_positions = self.chessboard.get_pieces_positions(self.side)  # 需要实现此方法
        random_piece = random.choice(pieces_positions)
        possible_moves = self.chessboard.get_possible_moves_with_coords(random_piece)
        if not possible_moves:
            raise Exception("没有可行的移动。")
        random_move = random.choice(possible_moves)
        success = self.chessboard.move_piece_with_coords(random_piece, random_move)
        if not success:
            raise Exception("移动失败。")
```

#### 实现main.py进行测试

```python
from RandomBot import RandomBot
from ChessBoard import ChessBoard
chess_board = ChessBoard()
chess_board.set_initial_pieces()
random_bot = RandomBot(chess_board, "red")

while True:
    random_bot.make_random_move()
    chess_board.print_board()
    user_input = input("Enter your move (e.g., 'e2 e4') or 'quit' to exit: ")
    if user_input.lower() == 'quit':
        break
    src, dest = user_input.split()
    chess_board.move_piece(src, dest)
    chess_board.print_board()
```

![image-20240217223138369](/images/python实现中国象棋（二）/image-20240217223138369.png)

至此实现了简单的人机对弈交互接口，为实现更复杂的AI做准备。

### 添加输赢的判定

为了实现更复杂的AI，需要有对输赢的判定。

