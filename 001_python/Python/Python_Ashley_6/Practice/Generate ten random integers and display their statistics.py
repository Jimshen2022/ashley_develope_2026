"""Generate ten random integers and display their statistics."""
import random
from typing import List

def main() -> None:
    numbers = [random.randint(1, 100) for _ in range(10)]
    print("生成的随机数: ", numbers)
    print("最大值: ", max(numbers))
    print("最小值: ", min(numbers))

if __name__ == "__main__":
    main()