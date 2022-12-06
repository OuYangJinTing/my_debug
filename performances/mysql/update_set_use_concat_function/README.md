**测试 mysql5.6 在以下情况执行 update 语句的性能**

执行测试 `docker-compose run --rm ruby ruby /root/script.rb`，[测试脚本](./script.rb)

- 资源限制 1 cpu && 512M memory
- 一千万单表数据量
- set values 语句使用了 concat 函数
- 批量更新选中的 1000/10000 条数据的性能
