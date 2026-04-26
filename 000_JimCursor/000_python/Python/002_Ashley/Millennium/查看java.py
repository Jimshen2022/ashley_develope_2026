import os
import sys
from pyspark.sql import SparkSession

# 动态获取 Conda 环境中的 Java 路径
java_home = os.path.join(os.environ['CONDA_PREFIX'], 'Library')
os.environ['JAVA_HOME'] = java_home

# 打印环境信息
print(f"Python版本: {sys.version}")
print(f"Java_HOME: {os.environ.get('JAVA_HOME')}")
print(f"PATH: {os.environ.get('PATH')}")

# 尝试创建SparkSession并捕获详细错误
try:
    spark = SparkSession.builder.appName("DebugSession").getOrCreate()
    print("SparkSession创建成功！")
    spark.stop()
except Exception as e:
    print(f"创建SparkSession时出错: {str(e)}")
    # 打印更详细的堆栈信息
    import traceback
    print(traceback.format_exc())