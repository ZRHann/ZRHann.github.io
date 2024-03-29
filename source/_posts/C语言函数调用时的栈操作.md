---
title: C语言函数调用时的栈操作
date: 2023-09-29 17:08:16
tags:
---

**压入栈的顺序是：参数、返回地址、原ebp、局部变量。（依次从低地址到高地址压入）**

在C语言中，当调用一个函数时，涉及的栈操作和参数的传递通常依赖于目标架构和使用的调用约定。但是，我们可以描述一个典型的（并且是常见的）情景，即x86架构上的`cdecl`调用约定。请注意，其他架构和调用约定可能有所不同。

在`cdecl`调用约定中，当调用一个函数时，栈的操作顺序大致如下：

#### **参数传递**：

- 函数参数从右到左（即从最后一个参数到第一个参数）的顺序压入栈中。这意味着第一个参数在栈的顶部，而最后一个参数在栈的底部。

#### **调用指令执行**：

- 执行`call`指令。这会将返回地址（即`call`指令后的下一个指令的地址）压入栈。

#### **函数入口**：

- 一旦进入函数，`ebp`（基指针寄存器）通常会被压入栈，以便在函数返回时可以恢复它。
- `ebp`然后设置为当前的`esp`（栈指针寄存器）值。这标志着一个新的栈帧的开始。
- 局部变量为函数预留空间，通常通过减少`esp`来完成。

#### **函数执行**：

- 在函数体中，通过基于`ebp`的偏移来访问局部变量和参数。
- 如果函数调用其他函数，上述过程会递归进行。

#### **函数返回**：

- 函数结束前，局部变量的空间会被释放，通常是通过增加`esp`来实现。
- 原始的`ebp`值从栈中弹出，恢复调用者的栈帧。
- 执行`ret`指令，这会从栈中弹出返回地址并跳转到那里。

#### **调用者函数恢复**：

- 如果使用`cdecl`调用约定，调用者需要清理传递给被调函数的参数。这是通过增加`esp`来实现的。

请注意，这只是一个简化的概述，真实情况可能因编译器优化和特定情境而异。而且，不同的调用约定和架构（如x86-64、ARM等）可能会有所不同的栈操作和参数传递机制。