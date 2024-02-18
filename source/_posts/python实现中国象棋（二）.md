---
title: python实现中国象棋（二）
date: 2024-02-17 22:07:01
tags:
typora-root-url: ..
---





## 实现随机落子的RandomBot

该bot只是从所有可能的落子方式中随机选取一种。

### 增加几个工具方法

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

### 实现RandomBot.py

其中，ChessBoard和ChessPiece类放到了ChessBoard.py

```python
import random
from ChessBoard import ChessBoard

class RandomBot:
    def __init__(self, chessboard: ChessBoard, side: str):
        self.chessboard = chessboard
        self.side = side

    def make_random_move(self):
        pieces_positions = self.chessboard.get_pieces_positions(self.side)  
        random_piece = random.choice(pieces_positions)
        possible_moves = self.chessboard.get_possible_moves_with_coords(random_piece)
        if not possible_moves:
            raise Exception("没有可行的移动。")
        random_move = random.choice(possible_moves)
        success = self.chessboard.move_piece_with_coords(random_piece, random_move)
        if not success:
            raise Exception("移动失败。")
```

### 实现main.py进行测试

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

## 添加对输赢的判定

为了实现更复杂的AI，需要有对输赢的判定。

在move_piece中修改即可。如果该move吃掉了将/帅，则将self.winner设置。

```python
    def move_piece(self, src: str, dest: str) -> bool:
        """移动棋子。

        Args:
            src (str): 源位置，例如 'a1'。
            dest (str): 目标位置，例如 'a2'。

        Returns:
            bool: 移动是否成功。
        """
        src_col, src_row = ord(src[0]) - ord('a'), int(src[1])
        dest_col, dest_row = ord(dest[0]) - ord('a'), int(dest[1])
        
        # 检查源位置和目标位置是否合法
        if not (0 <= src_row < 10 and 0 <= src_col < 9) or not (0 <= dest_row < 10 and 0 <= dest_col < 9):
            print("Invalid move: Out of bounds")
            return False
        
        moving_piece = self.board[src_row][src_col]
        if moving_piece is None:
            print("Invalid move: No piece at source")
            return False
        
        # 获取棋子的可能移动位置
        possible_moves = self.get_possible_moves(src)
        if (dest_row, dest_col) not in possible_moves:
            print("Invalid move: Not a legal move for this piece")
            return False
        
        # 执行移动
        target_piece = self.board[dest_row][dest_col]
        self.board[dest_row][dest_col] = moving_piece
        self.board[src_row][src_col] = None
        print(f"Moved {moving_piece.name} from {src} to {dest}")
        
        # 检查是否吃掉了对方的将/帅
        if target_piece is not None:
            if target_piece.name == '将' or target_piece.name == '帅':
                self.winner = 'black' if target_piece.side == 'red' else 'red'
                print(f"{self.winner} wins!")
        return True
```

## 对弈算法简介

对弈游戏常用算法有**极小化极大算法（Minimax Algorithm）**、**α-β剪枝（Alpha-Beta Pruning）**、**迭代加深搜索（Iterative Deepening Search）**、**蒙特卡洛树搜索（Monte Carlo Tree Search, MCTS）**等。

其中，MCTS基于一种有趣的思想：对于某个局面，使用两个RandomBot快速对弈数千局，可以估测该局面的胜率。

先尝试实现MCTS。

对MCTS的学习，参考https://zhuanlan.zhihu.com/p/53948964。

结合工具https://vgarciasc.github.io/mcts-viz/，可以清晰地了解MCTS的步骤。对该工具的使用，还可以参考https://www.youtube.com/watch?v=ghhznqBoESY。



## 实现MCTSBot

### 添加几个工具方法

```python
    def get_legal_moves(self, side: str) -> list:
        """获取指定颜色方的所有合法移动。

        Args:
            side (str): 棋子的颜色，"black" 或 "red"。

        Returns:
            list: 所有合法移动的列表，每个移动为 (src, dest) 形式的元组。
        """
        positions = self.get_pieces_positions(side)
        legal_moves = []
        for position in positions:
            possible_moves = self.get_possible_moves_with_coords(position)
            for move in possible_moves:
                legal_moves.append((position, move))
        return legal_moves
    
    def copy(self):
        """复制棋盘。

        Returns:
            ChessBoard: 复制的棋盘。
        """
        new_board = ChessBoard()
        new_board.board = [row[:] for row in self.board]
        new_board.winner = self.winner
        return new_board
    
```

### 修几个bug

_get_knight_moves中，leg_positions有误。更正为：

```python
move_vectors = [(-2, -1), (-2, 1), (2, -1), (2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2)]
leg_positions = [(-1, 0), (-1, 0), (1, 0), (1, 0), (0, -1), (0, 1), (0, -1), (0, 1)]
```



### MCTSBot.py

```python
import random
import math
from ChessBoard import ChessBoard

class MCTSNode:
    def __init__(self, chessboard: ChessBoard, move=None, parent=None, side=None):
        self.chessboard = chessboard.copy()  # 假设ChessBoard有一个复制自身的方法
        self.move = move  # 导致此节点的移动
        self.parent = parent  # 父节点
        self.children = []  # 子节点
        self.wins = 0  # 赢的模拟次数
        self.visits = 0  # 访问次数
        self.side = side  # 当前节点代表的玩家
        self.untried_moves = self.chessboard.get_legal_moves(side)  # 尚未尝试的移动

        if move:
            self.chessboard.move_piece_with_coords(move[0], move[1])

    def select_child(self):
        """选择子节点, 使用UCT算法."""
        s = sorted(self.children, key=lambda c: c.wins / c.visits + math.sqrt(2 * math.log(self.visits) / c.visits))[-1]
        return s

    def expand(self):
        """扩展一个新的子节点."""
        move = self.untried_moves.pop()
        next_side = 'red' if self.side == 'black' else 'black'
        child_node = MCTSNode(self.chessboard, move, self, next_side)
        self.children.append(child_node)
        return child_node

    def update(self, result):
        """更新节点的信息."""
        self.visits += 1
        if self.side == result:
            self.wins += 1

    def is_terminal_node(self):
        """判断是否为终止节点，即游戏结束的节点."""
        return self.chessboard.winner is not None

class MCTSBot:
    def __init__(self, chessboard: ChessBoard, side: str, iteration_limit=10000):
        self.chessboard = chessboard
        self.side = side
        self.iteration_limit = iteration_limit

    def make_move(self):
        root = MCTSNode(chessboard=self.chessboard, side=self.side)

        for _ in range(self.iteration_limit):
            # 选择阶段
            node = root
            while node.untried_moves == [] and node.children != []:
                node = node.select_child()

            # 扩展阶段
            if node.untried_moves != []:
                node = node.expand()

            # 模拟阶段
            outcome = self.simulate_random_game(node.chessboard, node.side)

            # 回溯阶段
            while node is not None:
                node.update(outcome)
                node = node.parent

        best_move = sorted(root.children, key=lambda c: c.wins / c.visits)[-1].move
        self.chessboard.move_piece_with_coords(best_move[0], best_move[1])
        return best_move

    def simulate_random_game(self, chessboard: ChessBoard, side: str):
        """随机模拟游戏至结束，返回胜者."""
        while chessboard.winner is None:
            pieces_positions = chessboard.get_pieces_positions(side)
            if not pieces_positions:
                break
            random_piece = random.choice(pieces_positions)
            possible_moves = chessboard.get_possible_moves_with_coords(random_piece)
            if not possible_moves:
                break
            random_move = random.choice(possible_moves)
            chessboard.move_piece_with_coords(random_piece, random_move)
            side = 'red' if side == 'black' else 'black'
        return chessboard.winner

```

### 调试

1. 初步测试发现效果不佳。
   使用棋盘
   ![image-20240218160549482](/images/python实现中国象棋（二）/image-20240218160549482.png)

进行测试，发现红色永远不会执行必胜策略（吃将），猜测对胜负的判定有问题。

children的win应该对应于root的lose，所以通过

```python
sorted(root.children, key=lambda c: c.wins / c.visits)[-1].move
```

来排序应该是错误的。

改为

```python
sorted(root.children, key=lambda c: (c.visits - c.wins) / c.visits)[-1].move
```

2. 另一个问题是，游戏结束后，get_possible_moves和get_legal_moves应该返回[]。

添加

```python
if self.winner is not None:
	return []
```

即可。

3. 修改MCTSBot的init，move应该在untried_moves赋值前。

   ```python
       def __init__(self, chessboard: ChessBoard, move=None, parent=None, side=None):
           self.chessboard = chessboard.copy()  # 假设ChessBoard有一个复制自身的方法
           self.move = move  # 导致此节点的移动
           self.parent = parent  # 父节点
           self.children = []  # 子节点
           self.wins = 0  # 赢的模拟次数
           self.visits = 0  # 访问次数
           self.side = side  # 当前节点代表的玩家
           if move:
               self.chessboard.move_piece_with_coords(move[0], move[1])
           self.untried_moves = self.chessboard.get_legal_moves(side)  # 尚未尝试的移动
   ```

4. ```python
   outcome = self.simulate_random_game(node.chessboard, node.side)
   ```

   应改为

   ```python
   outcome = self.simulate_random_game(node.chessboard.copy(), node.side)
   ```

### 效果

迭代次数10000时，对于将军，MCTSBot能正确防守。对于吃其他的子，MCTSBot一般无法正确防守。棋力还是较弱。



下一篇实现AlphaBetaBot。
