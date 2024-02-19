---
title: python实现中国象棋（三）
date: 2024-02-18 20:04:10
tags:
typora-root-url: ..
---



## AlphaBeta剪枝简介

https://blog.csdn.net/weixin_42165981/article/details/103263211

## 实现AlphaBetaBot

```python
from ChessBoard import ChessBoard
class AlphaBetaBot:
    def __init__(self, chessboard: ChessBoard, side: str, depth: int):
        self.chessboard = chessboard
        self.side = side
        self.depth = depth  # 搜索深度

    def evaluate_board(self, board: ChessBoard) -> int:
        # 定义棋子价值
        piece_value = {
            '将': 900, '帅': 900,
            '车': 90, '炮': 50,
            '马': 40, '象': 20, '士': 20,
            '卒': 10, '兵': 10
        }
        
        if board.winner == self.side:
            return float('inf')
        if board.winner == self.opposite_side():
            return float('-inf')
        
        # 评估棋盘
        score = 0
        for row in board.board:
            for piece in row:
                if piece is not None:
                    value = piece_value[piece.name]
                    if piece.side == self.side:
                        score += value
                    else:
                        score -= value

        return score

    def alphabeta(self, board: ChessBoard, depth: int, alpha: int, beta: int, maximizingPlayer: bool) -> int:
        """
        Alpha-Beta剪枝算法的实现。
        """
        if depth == 0:
            return self.evaluate_board(board)

        if maximizingPlayer:
            maxEval = float('-inf')
            for move in board.get_legal_moves(self.side):
                new_board = board.copy()
                new_board.move_piece_with_coords(move[0], move[1])
                eval = self.alphabeta(new_board, depth - 1, alpha, beta, False)
                maxEval = max(maxEval, eval)
                alpha = max(alpha, eval)
                if beta <= alpha:
                    break
            return maxEval
        else:
            minEval = float('inf')
            for move in board.get_legal_moves(self.opposite_side()):
                new_board = board.copy()
                new_board.move_piece_with_coords(move[0], move[1])
                eval = self.alphabeta(new_board, depth - 1, alpha, beta, True)
                minEval = min(minEval, eval)
                beta = min(beta, eval)
                if beta <= alpha:
                    break
            return minEval

    def opposite_side(self) -> str:
        """
        获取对手的棋子颜色。
        """
        return 'black' if self.side == 'red' else 'red'

    def make_move(self):
        """
        执行一个移动。使用Alpha-Beta算法找到最佳移动。
        """
        best_score = float('-inf')
        best_move = None
        for move in self.chessboard.get_legal_moves(self.side):
            new_board = self.chessboard.copy()
            new_board.move_piece_with_coords(move[0], move[1])
            score = self.alphabeta(new_board, self.depth - 1, float('-inf'), float('inf'), False)
            if score > best_score:
                best_score = score
                best_move = move

        if best_move:
            self.chessboard.move_piece_with_coords(best_move[0], best_move[1])
        else:
            raise Exception("没有可行的移动。")

```

alpha-beta的逻辑是固定的。主要可调整的地方是evaluate_board函数。

这里只对每个子的分数进行累加，没有考虑棋子位置。使用3层搜索测试，效果明显比MCTS强。

后续应该对棋子的位置进行优化，例如过河的卒会比未过河的强等。

但是为了趣味性和便于测试，先将bot接入天天象棋。

