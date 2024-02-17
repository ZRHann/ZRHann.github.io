---
title: python实现中国象棋（一）
date: 2024-02-17 16:51:50
tags:
typora-root-url: ..
---



（大量使用了chatgpt）

## 一、初始棋盘设计和打印

打印初始棋盘，带颜色：

```python
class ChessPiece:
    def __init__(self, name, side, position):
        self.name = name  # 棋子名称
        self.side = side  # 所属方，'red' 或 'black'
        self.position = position  # 棋子位置，例如 'a1'

    def __str__(self):
        # 返回带有颜色的字符串
        if self.side == 'red':
            return f"\033[91m{self.name}\033[0m"
        else:
            return f"\033[94m{self.name}\033[0m"

# 初始化棋盘，0表示空位
chess_board = [[0 for _ in range(9)] for _ in range(10)]

# 初始化棋子，这里只示例几个棋子，剩余棋子可以按类似方式添加
pieces = [
    ChessPiece('车', 'red', 'a0'), ChessPiece('马', 'red', 'b0'),
    ChessPiece('象', 'red', 'c0'), ChessPiece('士', 'red', 'd0'),
    ChessPiece('帅', 'red', 'e0'), ChessPiece('士', 'red', 'f0'),
    ChessPiece('象', 'red', 'g0'), ChessPiece('马', 'red', 'h0'),
    ChessPiece('车', 'red', 'i0'), ChessPiece('炮', 'red', 'b2'),
    ChessPiece('炮', 'red', 'h2'), ChessPiece('兵', 'red', 'a3'),
    ChessPiece('兵', 'red', 'c3'), ChessPiece('兵', 'red', 'e3'),
    ChessPiece('兵', 'red', 'g3'), ChessPiece('兵', 'red', 'i3'),

    ChessPiece('车', 'black', 'a9'), ChessPiece('马', 'black', 'b9'),
    ChessPiece('象', 'black', 'c9'), ChessPiece('士', 'black', 'd9'),
    ChessPiece('将', 'black', 'e9'), ChessPiece('士', 'black', 'f9'),
    ChessPiece('象', 'black', 'g9'), ChessPiece('马', 'black', 'h9'),
    ChessPiece('车', 'black', 'i9'), ChessPiece('炮', 'black', 'b7'),
    ChessPiece('炮', 'black', 'h7'), ChessPiece('卒', 'black', 'a6'),
    ChessPiece('卒', 'black', 'c6'), ChessPiece('卒', 'black', 'e6'),
    ChessPiece('卒', 'black', 'g6'), ChessPiece('卒', 'black', 'i6'),
]

# 将棋子放置到棋盘上
for piece in pieces:
    col, row = ord(piece.position[0]) - ord('a'), int(piece.position[1])
    chess_board[row][col] = piece

# 打印棋盘
for row in chess_board:
    for cell in row:
        if cell == 0:
            print('＋', end=' ')
        else:
            print(cell, end=' ')
    print()

```

效果：

![image-20240217220208211](/images/python从零开始实现中国象棋（一）初始棋盘设计/image-20240217220208211.png)

## 二、判断每个子的合法移动目标

将棋盘封装成一个类。 

设计一个成员函数，接收参数：棋子位置。 返回一个列表：该棋子可以走的位置。

### 封装现有框架

```python
class ChessPiece:
    def __init__(self, name, side, position):
        self.name = name  # 棋子名称
        self.side = side  # 所属方，'red' 或 'black'
        self.position = position  # 棋子位置，例如 'a1'

    def __str__(self):
        # 返回带有颜色的字符串，这里仅为示例，需要根据实际环境调整
        if self.side == 'red':
            return f"\033[91m{self.name}\033[0m"
        else:
            return f"\033[94m{self.name}\033[0m"

class ChessBoard:
    def __init__(self):
        # 初始化棋盘，使用二维数组表示，None表示空位
        self.board = [[None for _ in range(9)] for _ in range(10)]
        # 初始化棋子，这里省略了棋子的放置代码，参考之前的初始化方法

    def place_pieces(self, pieces):
        # 将棋子放置到棋盘上
        for piece in pieces:
            col, row = ord(piece.position[0]) - ord('a'), int(piece.position[1])
            self.board[row][col] = piece
            
    def print_board(self):
        for idx, row in enumerate(self.board):
            for cell in row:
                if cell is None:
                    print('＋', end=' ')
                else:
                    print(cell, end=' ')
            print()
            if(idx == 4):
                print('==========================')

    def get_possible_moves(self, position):
        # 根据棋子的位置计算可以移动到的位置
        col, row = ord(position[0]) - ord('a'), int(position[1])
        piece = self.board[row][col]
        if piece is None:
            return []  # 如果指定位置没有棋子，则返回空列表
        
        # 根据棋子类型返回可能的移动位置，这里以“马”为例
        if piece.name == '马':
            return self._get_knight_moves(row, col)
        # 可以根据需要添加其他棋子的移动逻辑
        else:
            return []

    def _get_knight_moves(self, row, col):
        # 计算马可以移动到的位置
        moves = []
        directions = [(-2, -1), (-2, 1), (2, -1), (2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2)]
        for dr, dc in directions:
            new_row, new_col = row + dr, col + dc
            if 0 <= new_row < 10 and 0 <= new_col < 9:  # 确保不超出棋盘范围
                # 这里简化处理，不考虑“马脚”
                moves.append((new_row, new_col))
        return moves

# 示例使用
pieces = [
    ChessPiece('车', 'red', 'a0'), ChessPiece('马', 'red', 'b0'),
    ChessPiece('象', 'red', 'c0'), ChessPiece('士', 'red', 'd0'),
    ChessPiece('帅', 'red', 'e0'), ChessPiece('士', 'red', 'f0'),
    ChessPiece('象', 'red', 'g0'), ChessPiece('马', 'red', 'h0'),
    ChessPiece('车', 'red', 'i0'), ChessPiece('炮', 'red', 'b2'),
    ChessPiece('炮', 'red', 'h2'), ChessPiece('兵', 'red', 'a3'),
    ChessPiece('兵', 'red', 'c3'), ChessPiece('兵', 'red', 'e3'),
    ChessPiece('兵', 'red', 'g3'), ChessPiece('兵', 'red', 'i3'),

    ChessPiece('车', 'black', 'a9'), ChessPiece('马', 'black', 'b9'),
    ChessPiece('象', 'black', 'c9'), ChessPiece('士', 'black', 'd9'),
    ChessPiece('将', 'black', 'e9'), ChessPiece('士', 'black', 'f9'),
    ChessPiece('象', 'black', 'g9'), ChessPiece('马', 'black', 'h9'),
    ChessPiece('车', 'black', 'i9'), ChessPiece('炮', 'black', 'b7'),
    ChessPiece('炮', 'black', 'h7'), ChessPiece('卒', 'black', 'a6'),
    ChessPiece('卒', 'black', 'c6'), ChessPiece('卒', 'black', 'e6'),
    ChessPiece('卒', 'black', 'g6'), ChessPiece('卒', 'black', 'i6'),
]

chess_board = ChessBoard()
chess_board.place_pieces(pieces)
chess_board.print_board()
```

### 优化的棋盘打印函数

打印每个点的坐标

```python
    def print_board(self):
        # 打印列坐标
        col_labels = '  '.join(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'])
        print(f"\033[92m  {col_labels}\033[0m")  # 绿色
        for idx, row in enumerate(self.board):
            row_label = f"\033[92m{idx}\033[0m"  # 行号，绿色
            print(row_label, end=' ')
            for cell in row:
                if cell is None:
                    print('＋', end=' ')
                else:
                    print(cell, end=' ')
            print()  # 新的一行
            if idx == 4:  # 在第五行后打印楚河汉界分界线
                print('' + '============================')
        # 打印列坐标
        print(f"\033[92m  {col_labels}\033[0m")  # 绿色   
```

效果

![image-20240217220324100](/images/python从零开始实现中国象棋（一）初始棋盘设计/image-20240217220324100.png)

### get_possible_moves框架

```python
	def get_possible_moves(self, position):
        col, row = ord(position[0]) - ord('a'), int(position[1])
        piece = self.board[row][col]
        if piece is None:
            return []  # 如果指定位置没有棋子，则返回空列表

        # 根据棋子类型调用对应的移动逻辑
        if piece.name == '车':
            return self._get_rook_moves(row, col)
        elif piece.name == '马':
            return self._get_knight_moves(row, col)
        elif piece.name == '象' or piece.name == '相':
            return self._get_elephant_moves(row, col)
        elif piece.name == '士' or piece.name == '仕':
            return self._get_guard_moves(row, col)
        elif piece.name == '将' or piece.name == '帅':
            return self._get_king_moves(row, col)
        elif piece.name == '炮':
            return self._get_cannon_moves(row, col)
        elif piece.name == '兵' or piece.name == '卒':
            return self._get_pawn_moves(row, col)
        else:
            return []

    # 假设的棋子移动逻辑函数，具体实现待补充
    def _get_rook_moves(self, row, col):
        # 车的移动逻辑
        pass

    def _get_knight_moves(self, row, col):
        # 马的移动逻辑
        pass

    def _get_elephant_moves(self, row, col):
        # 象的移动逻辑
        pass

    def _get_guard_moves(self, row, col):
        # 士的移动逻辑
        pass

    def _get_king_moves(self, row, col):
        # 将或帅的移动逻辑
        pass

    def _get_cannon_moves(self, row, col):
        # 炮的移动逻辑
        pass

    def _get_pawn_moves(self, row, col):
        # 兵或卒的移动逻辑
        pass
```

总共也就7种棋子逻辑。

### 测试代码

使用如下方法测试。修改棋盘布局即可。

```python
if __name__ == '__main__':
    pieces_test1 = [
        ChessPiece('马', 'red', 'a6'), ChessPiece('车', 'red', 'a9')
    ]
    chess_board = ChessBoard()
    chess_board.place_pieces(pieces_test1)
    chess_board.print_board()
    print(ChessBoard.coords_to_alphanumeric(chess_board.get_possible_moves('a9')))
```

### 车

```python
def _get_rook_moves(self, row, col):
        possible_moves = []
        directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]  # 右、下、左、上
        for dr, dc in directions:
            r, c = row + dr, col + dc
            while 0 <= r < 10 and 0 <= c < 9:
                if self.board[r][c] is None:
                    possible_moves.append((r, c))  # 添加空位置
                else:
                    if self.board[r][c].side != self.board[row][col].side:
                        possible_moves.append((r, c))  # 可以吃掉对方棋子
                    break  # 遇到任何棋子停止检查这个方向
                r += dr
                c += dc
        return possible_moves
```

### 士

不能超出九宫格范围。 

落点不能有己方棋子。

```python
    def _get_guard_moves(self, row, col, side):
        moves = []
        directions = [(-1, -1), (-1, 1), (1, -1), (1, 1)]  # 斜线移动的四个方向
        # 红方和黑方的九宫格范围
        palace_bounds = {
            'red': ((0, 2), (3, 5)),
            'black': ((7, 9), (3, 5))
        }
        row_bounds, col_bounds = palace_bounds[side]

        for drow, dcol in directions:
            new_row, new_col = row + drow, col + dcol
            # 检查是否在九宫内以及是否有己方棋子
            if row_bounds[0] <= new_row <= row_bounds[1] and col_bounds[0] <= new_col <= col_bounds[1]:
                target_piece = self.board[new_row][new_col]
                if target_piece is None or target_piece.side != side:
                    moves.append((new_row, new_col))
        
        return moves
```

### 将帅

需要在九宫格内。 

需要水平或垂直移动一格子。 

不能是自己的棋子。 

如果正对对方的king，可以吃掉。

```python
def _get_king_moves(self, row, col):
        possible_moves = []
        current_piece = self.board[row][col]
        # 定义移动方向：上、下、左、右
        directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        # 定义九宫格范围
        king_zone = {
            'red': (0, 2, 3, 5),
            'black': (7, 9, 3, 5)
        }
        # 获取当前棋子的九宫格范围
        zone = king_zone[current_piece.side]

        # 检查水平和垂直方向移动一格的合法性
        for dr, dc in directions:
            new_row, new_col = row + dr, col + dc
            if zone[0] <= new_row <= zone[1] and zone[2] <= new_col <= zone[3]:
                target_piece = self.board[new_row][new_col]
                if target_piece is None or target_piece.side != current_piece.side:
                    possible_moves.append((new_row, new_col))

        # 检查垂直方向上是否直接对面对方的“将”或“帅”
        direction_to_check = 1 if current_piece.side == 'red' else -1  # 红方向下检查，黑方向上检查
        for i in range(1, 10):  # 最多检查棋盘的高度
            check_row = row + i * direction_to_check
            if check_row < 0 or check_row > 9:  # 超出棋盘范围
                break
            target_piece = self.board[check_row][col]
            if target_piece is not None:
                if target_piece.name in ['帅', '将'] and target_piece.side != current_piece.side:
                    possible_moves.append((check_row, col))  # 直接对面对方的“将”或“帅”，可以移动
                break  # 遇到任何棋子都停止检查

        return possible_moves
```

### 兵卒

楚河汉界前，只能前进。楚河后，可以前进或左右。 

注意，棋盘上面是红色，下面是黑色。也就是红方向下移动（1），黑方向上移动（-1）。

可以吃掉对方棋子。但不能走到自己方的棋子。

```python
    def _get_pawn_moves(self, row, col):
        possible_moves = []
        current_piece = self.board[row][col]
        move_direction = 1 if current_piece.side == 'red' else -1  # 红方向下，黑方向上

        # 楚河汉界的定义：红方的楚河汉界是第5行（从0开始计数），黑方的是第4行
        river_boundary = 4 if current_piece.side == 'red' else 5

        # 前进一步的移动
        forward_row = row + move_direction
        if 0 <= forward_row < 10:
            if self.board[forward_row][col] is None or self.board[forward_row][col].side != current_piece.side:
                possible_moves.append((forward_row, col))

        # 楚河汉界后的左右移动
        if (current_piece.side == 'red' and row > river_boundary) or (current_piece.side == 'black' and row < river_boundary):
            for side_step in [-1, 1]:  # 左移和右移
                side_col = col + side_step
                if 0 <= side_col < 9:
                    if self.board[row][side_col] is None or self.board[row][side_col].side != current_piece.side:
                        possible_moves.append((row, side_col))

        return possible_moves
```

### 炮

```python
    def _get_cannon_moves(self, row, col):
        possible_moves = []
        current_piece = self.board[row][col]

        # 检查横向和纵向的移动
        directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]  # 右、左、下、上
        for dr, dc in directions:
            obstacle_found = False  # 标记是否找到跳板（障碍）
            for step in range(1, 10):  # 假设棋盘最大不超过10步
                new_row, new_col = row + step * dr, col + step * dc
                # 检查新位置是否超出棋盘
                if not (0 <= new_row < 10 and 0 <= new_col < 9):
                    break  # 超出棋盘范围

                target_piece = self.board[new_row][new_col]
                if target_piece is None:
                    if not obstacle_found:  # 如果还没有找到障碍，可以移动
                        possible_moves.append((new_row, new_col))
                else:
                    if not obstacle_found:
                        obstacle_found = True  # 找到第一个障碍
                    else:  # 如果已经找到障碍，检查这个位置的棋子是否为敌方棋子
                        if target_piece.side != current_piece.side:
                            possible_moves.append((new_row, new_col))  # 可以跳吃
                        break  # 无论是否跳吃成功，之后的位置都不再考虑

        return possible_moves
```

### 象相

1. 目标位置可以是空或敌方棋子，不能是己方棋子。 

2. 只能走田。
3. 不能出界。不能越过楚河汉界。
4. 田的中间不能有棋子。

```python
def _get_elephant_moves(self, row, col):
    possible_moves = []
    current_piece = self.board[row][col]
    directions = [(2, 2), (2, -2), (-2, 2), (-2, -2)]  # 定义“相”或“象”移动的四个方向
    river_boundary = 4 if current_piece.side == 'red' else 5  # 定义楚河汉界

    for dr, dc in directions:
        new_row, new_col = row + dr, col + dc
        middle_row, middle_col = row + dr // 2, col + dc // 2  # 计算“田”字中心的位置
        # 检查目标位置和“田”字中心的位置是否合法
        if 0 <= new_row < 10 and 0 <= new_col < 9 and self.board[middle_row][middle_col] is None:
            if current_piece.side == 'red' and new_row <= river_boundary or \
               current_piece.side == 'black' and new_row >= river_boundary:
                target_piece = self.board[new_row][new_col]
                if target_piece is None or target_piece.side != current_piece.side:
                    possible_moves.append((new_row, new_col))

    return possible_moves
```

### 马

1. 总共8个位置。 
2. 马脚不能有棋子。可以用数组提前表示8个位置的马脚在哪。 
3. 目标位置只能是空，或敌方棋子。不能是己方棋子。 
4. 不能越界。

```python
def _get_knight_moves(self, row, col):
    possible_moves = []
    current_piece = self.board[row][col]
    # 马的移动向量和对应的马脚位置
    move_vectors = [(-2, -1), (-2, 1), (2, -1), (2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2)]
    leg_positions = [(-1, 0), (-1, 0), (1, 0), (1, 0), (0, -1), (0, -1), (0, 1), (0, 1)]

    for i, (dr, dc) in enumerate(move_vectors):
        leg_row, leg_col = row + leg_positions[i][0], col + leg_positions[i][1]
        new_row, new_col = row + dr, col + dc
        # 检查马脚位置和目标位置是否合法：马脚位置不能有棋子，目标位置不能越界、不能有己方棋子
        if 0 <= new_row < 10 and 0 <= new_col < 9 and self.board[leg_row][leg_col] is None:
            target_piece = self.board[new_row][new_col]
            if target_piece is None or target_piece.side != current_piece.side:
                possible_moves.append((new_row, new_col))

    return possible_moves
```

## 三、实现落子交互逻辑

命令行输入，检查移动合法性，改变棋盘状态。

ChessBoard里添加两个函数：

```python
    def move_piece(self, src, dest):
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
        self.board[dest_row][dest_col] = moving_piece
        self.board[src_row][src_col] = None
        print(f"Moved {moving_piece.name} from {src} to {dest}")
        return True
    
    def start_game(self):
        while True:
            self.print_board()  # 打印当前棋盘状态
            user_input = input("Enter your move (e.g., 'e2 e4') or 'quit' to exit: ")
            if user_input.lower() == 'quit':
                break
            src, dest = user_input.split()
            self.move_piece(src, dest)
```

main的代码：

```python
if __name__ == '__main__':
    pieces_initial = [
        ChessPiece('车', 'red', 'a0'), ChessPiece('马', 'red', 'b0'),
        ChessPiece('象', 'red', 'c0'), ChessPiece('士', 'red', 'd0'),
        ChessPiece('帅', 'red', 'e0'), ChessPiece('士', 'red', 'f0'),
        ChessPiece('象', 'red', 'g0'), ChessPiece('马', 'red', 'h0'),
        ChessPiece('车', 'red', 'i0'), ChessPiece('炮', 'red', 'b2'),
        ChessPiece('炮', 'red', 'h2'), ChessPiece('兵', 'red', 'a3'),
        ChessPiece('兵', 'red', 'c3'), ChessPiece('兵', 'red', 'e3'),
        ChessPiece('兵', 'red', 'g3'), ChessPiece('兵', 'red', 'i3'),

        ChessPiece('车', 'black', 'a9'), ChessPiece('马', 'black', 'b9'),
        ChessPiece('象', 'black', 'c9'), ChessPiece('士', 'black', 'd9'),
        ChessPiece('将', 'black', 'e9'), ChessPiece('士', 'black', 'f9'),
        ChessPiece('象', 'black', 'g9'), ChessPiece('马', 'black', 'h9'),
        ChessPiece('车', 'black', 'i9'), ChessPiece('炮', 'black', 'b7'),
        ChessPiece('炮', 'black', 'h7'), ChessPiece('卒', 'black', 'a6'),
        ChessPiece('卒', 'black', 'c6'), ChessPiece('卒', 'black', 'e6'),
        ChessPiece('卒', 'black', 'g6'), ChessPiece('卒', 'black', 'i6'),
    ]
    pieces_test1 = [
        ChessPiece('马', 'black', 'g5'), 
        ChessPiece('马', 'black', 'g6'), 
        ChessPiece('马', 'red', 'e3'), 
    ]
    chess_board = ChessBoard()
    chess_board.place_pieces(pieces_initial)
    chess_board.print_board()
    chess_board.start_game()
```

![image-20240217220409445](/images/python从零开始实现中国象棋（一）初始棋盘设计/image-20240217220409445.png)

至此，可以实现命令行交互落子，能对不合法的落子给出提示，能正确改变棋盘状态。

此阶段完整代码：

https://github.com/ZRHann/chinese_chess/tree/a66cfe86c26b768a60a30d72fd5471db9097622a

下一部分将实现简单的对弈AI。
