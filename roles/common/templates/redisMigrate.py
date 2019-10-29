#!/usr/bin/env python
# -*- coding: utf-8 -*-

from redis import StrictRedis


def redis_data_migration():
    """
    实现方法:遍历源数据库中的键值对，判断类型，用对应的方法在目标数据库中创建对应键值对
    :return:
    """
    src_redis = StrictRedis(host='{{ redis_podIp.stdout }}')
    dst_redis = StrictRedis(host='{{ ks_redis_svc }}')

    print("Begin data migration:")

    # 遍历键值对
    try:
        for key in src_redis.keys():

            # 键值对数据类型
            key_type = str(src_redis.type(key))

            # 字符串类型键值对
            if key_type == 'string':
                # 获取源数据库value
                src_value = str(src_redis.get(key))
                # 在目标数据库中创建对应键值对
                dst_redis.set(key, src_value)
                # 插入到目标数据库中的值
                dst_value = dst_redis.get(key)
                print('Migrate source {} type data{}={} to destination value {}'
                      .format(key_type, key, src_value, dst_value))

            # 哈希字典类型键值对
            elif key_type == 'hash':
                # 获取源数据库value
                src_value = src_redis.hgetall(key)
                # 哈希类型键值对需要遍历子键值对进行处理
                for son_key in src_value:
                    son_key = str(son_key)
                    son_value = str(src_redis.hget(key, son_key))
                    # 在目标数据库中创建对应键值对
                    dst_redis.hset(key, son_key, son_value)
                # 插入到目标数据库中的值
                dst_value = dst_redis.hgetall(key)
                print('Migrate source {} type data{}={} to destination value {}'
                      .format(key_type, key, src_value, dst_value))

            # 列表类型键值对
            elif key_type == 'list':
                # 获取源数据库value，list类型可进行切片获取对应键值
                src_value = src_redis.lrange(key, 0, src_redis.llen(key))
                for value in src_value:
                    # 在目标数据库中创建对应键值对
                    dst_redis.rpush(key, str(value))
                # 插入到目标数据库中的值
                dst_value = dst_redis.lrange(key, 0, src_redis.llen(key))
                print('Migrate source {} type data{}={} to destination value {}'
                      .format(key_type, key, src_value, dst_value))

            # 集合类型键值对
            elif key_type == 'set':
                # 获取源数据库value
                src_value = src_redis.scard(key)
                for value in src_redis.smembers(key):
                    # 在目标数据库中插入对应键值对
                    dst_redis.sadd(key, str(value))
                dst_value = dst_redis.scard(key)
                print('Migrate source {} type data{}={} to destination value {}'
                      .format(key_type, key, src_value, dst_value))

            # 有序集合类型键值对
            elif key_type == 'zset':
                # 获取源数据库value
                src_value = src_redis.zcard(key)
                # zset类型可以进行键值对范围的选择，这段代码是选择0-100行的键值对
                for value in src_redis.zrange(key, 0, 100):
                    value = str(value)
                    score = int(src_redis.zscore(key, value))
                    # 在目标数据库中插入对应键值对
                    dst_redis.zadd(key, score, value)
                # 插入到目标数据库中的值
                dst_value = dst_redis.zcard(key)
                print('Migrate source {} type data{}={} to destination value {}'
                      .format(key_type, key, src_value, dst_value))

    except Exception as e:
        print("Something wrong happened！")
        print(e)


if __name__ == '__main__':
    redis_data_migration()
