---
title: python自定义logger
date: 2024-05-14 00:37:46
tags:
---

输出到控制台。

解决输出日志设置不生效的问题。

```python
import logging
def logger() -> logging.Logger:
    logger = logging.getLogger()
    handler = logging.StreamHandler()
    formatter = logging.Formatter('[%(asctime)s] [%(levelname)s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger

if __name__ == '__main__':
    logger().info("Hello, World!")
    # [2024-05-14 00:37:17] [INFO] Hello, World!
```

