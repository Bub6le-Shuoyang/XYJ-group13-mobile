## admins（管理员账户表）— 14 个字段

*代码块*
```sql
CREATE TABLE `admins` (
  `id`              BIGINT        NOT NULL AUTO_INCREMENT COMMENT '管理员主键',
  `username`        VARCHAR(64)   NOT NULL COMMENT '登录用户名',
  `password_hash`   VARCHAR(256)  NOT NULL COMMENT '密码哈希值（BCrypt等加密存储）',
  `real_name`       VARCHAR(64)   DEFAULT NULL COMMENT '真实姓名',
  `avatar_url`      VARCHAR(512)  DEFAULT NULL COMMENT '头像URL路径',
  `email`           VARCHAR(128)  DEFAULT NULL COMMENT '邮箱（可作为登录凭证）',
  `phone`           VARCHAR(20)   DEFAULT NULL COMMENT '手机号',
  `role`            TINYINT       DEFAULT 1 COMMENT '后台权限：1=普通管理员，2=高级管理员，3=超级管理员',
  `station_id`      BIGINT        DEFAULT NULL COMMENT '所属驿站ID，站点管理员必填',
  `status`          TINYINT       DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
  `last_login_time` DATETIME      DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip`   VARCHAR(45)   DEFAULT NULL COMMENT '最后登录IP（支持IPv6长度）',
  `created_at`      DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`),
  KEY `idx_station_id` (`station_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理员账户表';
```

设计要点：

- `role` 字段用于后台权限分级，移动端业务角色仍通过登录接口返回的 `role=ADMIN` 区分
- `station_id` 用于将站点管理员和驿站绑定，管理员工作台按该字段查询包裹和任务
- 当前移动端只支持账号密码登录，因此 `password_hash` 设为 `NOT NULL`
- `last_login_time` / `last_login_ip` 在每次登录成功时由 AdminAuthService 自动更新
- `email` 和 `username` 做唯一索引，均可作为账号密码登录凭证
- `updated_at` 使用 `ON UPDATE CURRENT_TIMESTAMP` 自动维护

---

## users（用户主表）— 19 个字段

*代码块*
```sql
CREATE TABLE `users` (
  `id`                BIGINT       NOT NULL AUTO_INCREMENT COMMENT '用户主键',
  `user_no`           VARCHAR(32)  NOT NULL COMMENT '用户编号（格式 U+时间戳，如 U20260406001）',
  `account`           VARCHAR(64)  NOT NULL COMMENT '登录账号，可为手机号/邮箱/用户名',
  `phone`             VARCHAR(20)  DEFAULT NULL COMMENT '手机号',
  `email`             VARCHAR(128) DEFAULT NULL COMMENT '邮箱',
  `password_hash`     VARCHAR(256) NOT NULL COMMENT '密码哈希值（当前移动端只支持账号密码登录）',
  `nickname`          VARCHAR(64)  DEFAULT NULL COMMENT '昵称',
  `avatar_url`        VARCHAR(512) DEFAULT NULL COMMENT '头像URL路径',
  `signature`         VARCHAR(256) DEFAULT NULL COMMENT '个性签名',
  `tags`              VARCHAR(256) DEFAULT NULL COMMENT '用户标签（逗号分隔）',
  `gender`            TINYINT      DEFAULT 0 COMMENT '性别：0=未知，1=男，2=女',
  `birthday`          DATE         DEFAULT NULL COMMENT '出生日期',
  `is_realname_auth`  TINYINT      DEFAULT 0 COMMENT '是否实名：0=否，1=是',
  `status`            TINYINT      DEFAULT 1 COMMENT '账户状态：0=禁用，1=正常，2=冻结',
  `last_login_time`   DATETIME     DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip`     VARCHAR(45)  DEFAULT NULL COMMENT '最后登录IP',
  `register_ip`       VARCHAR(45)  DEFAULT NULL COMMENT '注册时的IP地址',
  `created_at`        DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`        DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_no` (`user_no`),
  UNIQUE KEY `uk_account` (`account`),
  UNIQUE KEY `uk_email` (`email`),
  KEY `idx_phone` (`phone`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户主表';
```

设计要点：

- 比 admins 多了 5 个字段，核心差异是 users 面向 C 端村民用户，需要更丰富的个人资料（性别、生日、签名、标签）
- 当前移动端只支持账号密码登录，不支持验证码登录、短信登录、邮箱验证码登录和第三方登录
- `account` 是统一登录账号，`phone` / `email` 可作为资料字段和辅助登录凭证
- `tags` 用逗号分隔字符串存储而非关联表，适合标签量不大、查询不需要联合的场景
- `user_no` 是业务编号，格式规则为 `U` + 时间戳序号，在 createUser 接口中若不传则自动生成
- 索引方面：`user_no`、`account`、`email` 做唯一索引，`phone` 和 `status` 做普通索引支持列表查询和搜索过滤，`created_at` 支持按注册时间排序

---

## couriers（骑手账户表）— 14 个字段

*代码块*
```sql
CREATE TABLE `couriers` (
  `id`              BIGINT        NOT NULL AUTO_INCREMENT COMMENT '骑手主键',
  `courier_no`      VARCHAR(32)   NOT NULL COMMENT '骑手编号，如 COURIER-013',
  `account`         VARCHAR(64)   NOT NULL COMMENT '登录账号',
  `password_hash`   VARCHAR(256)  NOT NULL COMMENT '密码哈希值',
  `name`            VARCHAR(64)   NOT NULL COMMENT '骑手姓名',
  `phone`           VARCHAR(20)   DEFAULT NULL COMMENT '联系电话',
  `avatar_url`      VARCHAR(512)  DEFAULT NULL COMMENT '头像URL',
  `station_id`      BIGINT        DEFAULT NULL COMMENT '服务驿站ID',
  `level_name`      VARCHAR(64)   DEFAULT '普通配送员 Lv.1' COMMENT '骑手等级名称',
  `level_progress`  DECIMAL(5,2)  DEFAULT 0 COMMENT '等级进度，范围 0-1',
  `monthly_rank`    INT           DEFAULT 0 COMMENT '本月排名',
  `status`          TINYINT       DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
  `created_at`      DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_courier_no` (`courier_no`),
  UNIQUE KEY `uk_account` (`account`),
  KEY `idx_station_id` (`station_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='骑手账户表';
```

设计要点：

- 骑手独立建表，便于和村民用户、站点管理员区分权限和统计口径
- `station_id` 绑定服务驿站，任务大厅可按站点或附近区域过滤任务
- `level_name`、`level_progress`、`monthly_rank` 直接支撑骑手个人页展示
- `account` + `password_hash` 支撑当前账号密码登录方式

---

## stations（驿站表）— 12 个字段

*代码块*
```sql
CREATE TABLE `stations` (
  `id`             BIGINT        NOT NULL AUTO_INCREMENT COMMENT '驿站主键',
  `station_no`     VARCHAR(32)   NOT NULL COMMENT '驿站编号，如 ST-001',
  `name`           VARCHAR(64)   NOT NULL COMMENT '驿站名称',
  `address`        VARCHAR(255)  NOT NULL COMMENT '驿站地址',
  `lat`            DECIMAL(10,6) DEFAULT NULL COMMENT '纬度',
  `lng`            DECIMAL(10,6) DEFAULT NULL COMMENT '经度',
  `phone`          VARCHAR(20)   DEFAULT NULL COMMENT '联系电话',
  `opening_hours`  VARCHAR(64)   DEFAULT NULL COMMENT '营业时间',
  `status`         TINYINT       DEFAULT 1 COMMENT '状态：0=停用，1=启用',
  `created_at`     DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`     DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`     DATETIME      DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_station_no` (`station_no`),
  KEY `idx_location` (`lat`, `lng`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='驿站表';
```

设计要点：

- 驿站表支撑附近驿站地图、管理员工作台和骑手任务归属
- `lat` / `lng` 建联合索引，便于按用户当前位置计算附近驿站
- `opening_hours`、`phone` 用于驿站详情和客服入口展示

---

## packages（收件包裹表）— 19 个字段

*代码块*
```sql
CREATE TABLE `packages` (
  `id`                BIGINT        NOT NULL AUTO_INCREMENT COMMENT '包裹主键',
  `package_no`        VARCHAR(32)   NOT NULL COMMENT '包裹业务编号，如 PKG-001',
  `pickup_code`       VARCHAR(16)   NOT NULL COMMENT '取件码，由骑手上门核验',
  `name`              VARCHAR(128)  NOT NULL COMMENT '包裹名称',
  `sender_name`       VARCHAR(64)   DEFAULT NULL COMMENT '来源方，如县医院/县城商超',
  `receiver_user_id`  BIGINT        DEFAULT NULL COMMENT '收件用户ID，关联 users.id',
  `receiver_name`     VARCHAR(64)   NOT NULL COMMENT '收件人',
  `receiver_phone`    VARCHAR(20)   DEFAULT NULL COMMENT '收件电话',
  `address`           VARCHAR(255)  NOT NULL COMMENT '配送地址',
  `weight`            DECIMAL(10,2) DEFAULT 0 COMMENT '包裹重量',
  `estimated_fee`     DECIMAL(10,2) DEFAULT 0 COMMENT '预估费用，收件业务可为0',
  `reward_amount`     DECIMAL(10,2) DEFAULT 0 COMMENT '骑手配送奖励',
  `status`            VARCHAR(32)   NOT NULL COMMENT 'PENDING_INBOUND/IN_STOCK/TASK_PUBLISHED/ASSIGNED/COMPLETED',
  `station_id`        BIGINT        DEFAULT NULL COMMENT '当前驿站ID',
  `courier_id`        BIGINT        DEFAULT NULL COMMENT '当前骑手ID',
  `lat`               DECIMAL(10,6) DEFAULT NULL COMMENT '配送纬度',
  `lng`               DECIMAL(10,6) DEFAULT NULL COMMENT '配送经度',
  `created_at`        DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`        DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_package_no` (`package_no`),
  UNIQUE KEY `uk_pickup_code` (`pickup_code`),
  KEY `idx_receiver_user_id` (`receiver_user_id`),
  KEY `idx_station_id` (`station_id`),
  KEY `idx_courier_id` (`courier_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收件包裹表';
```

设计要点：

- 当前业务只保留收件/配送链路，不保存寄件订单状态和 `orderCode`
- `pickup_code` 由骑手核验，不由站点管理员核验
- `status` 对齐移动端 `PackageStatus`：待入库、已入库、待骑手接单、派送中、已签收
- `receiver_user_id`、`station_id`、`courier_id` 保证用户、驿站、骑手、包裹之间的数据关联

---

## package_timelines（包裹流转记录表）— 5 个字段

*代码块*
```sql
CREATE TABLE `package_timelines` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '流转记录主键',
  `package_id`  BIGINT       NOT NULL COMMENT '关联 packages.id',
  `status`      VARCHAR(32)  DEFAULT NULL COMMENT '记录产生时的包裹状态',
  `content`     VARCHAR(255) NOT NULL COMMENT '流转文案',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_package_id_created_at` (`package_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='包裹流转记录表';
```

设计要点：

- 包裹详情页和卡片时间线均从该表聚合生成
- 每次入库、出库、发布任务、抢单、核验签收都应追加流转记录
- `status` 字段用于前端按节点高亮展示

---

## delivery_tasks（配送任务表）— 15 个字段

*代码块*
```sql
CREATE TABLE `delivery_tasks` (
  `id`              BIGINT        NOT NULL AUTO_INCREMENT COMMENT '任务主键',
  `task_no`         VARCHAR(32)   NOT NULL COMMENT '任务编号，如 TASK-001',
  `package_id`      BIGINT        NOT NULL COMMENT '关联 packages.id',
  `station_id`      BIGINT        NOT NULL COMMENT '发布任务的驿站ID',
  `courier_id`      BIGINT        DEFAULT NULL COMMENT '抢单骑手ID',
  `pickup_address`  VARCHAR(255)  NOT NULL COMMENT '取件地址，通常为驿站地址',
  `deliver_address` VARCHAR(255)  NOT NULL COMMENT '送达地址',
  `reward_amount`   DECIMAL(10,2) DEFAULT 0 COMMENT '配送奖励',
  `status`          VARCHAR(32)   NOT NULL COMMENT 'AVAILABLE/ASSIGNED/DELIVERING/COMPLETED',
  `deliver_image`   VARCHAR(512)  DEFAULT NULL COMMENT '送达凭证图片',
  `remark`          VARCHAR(255)  DEFAULT NULL COMMENT '备注',
  `grabbed_at`      DATETIME      DEFAULT NULL COMMENT '抢单时间',
  `completed_at`    DATETIME      DEFAULT NULL COMMENT '完成时间',
  `created_at`      DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_no` (`task_no`),
  UNIQUE KEY `uk_package_id` (`package_id`),
  KEY `idx_station_status` (`station_id`, `status`),
  KEY `idx_courier_status` (`courier_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='配送任务表';
```

设计要点：

- `task_no` 是骑手任务接口的业务 ID，骑手抢单、取件、核验取件码都必须使用该 ID
- `package_id` 做唯一索引，保证一个包裹同一时间只有一个配送任务
- 管理员发布配送任务后生成任务，包裹状态变为 `TASK_PUBLISHED`
- 骑手核验取件码后任务状态变为 `COMPLETED`，包裹状态同步变为 `COMPLETED`

---

## courier_earnings（骑手收益流水表）— 9 个字段

*代码块*
```sql
CREATE TABLE `courier_earnings` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '收益流水主键',
  `courier_id`  BIGINT        NOT NULL COMMENT '关联 couriers.id',
  `task_id`     BIGINT        NOT NULL COMMENT '关联 delivery_tasks.id',
  `amount`      DECIMAL(10,2) NOT NULL COMMENT '收益金额',
  `type`        VARCHAR(32)   DEFAULT 'DELIVERY_REWARD' COMMENT '收益类型',
  `status`      VARCHAR(32)   DEFAULT 'SETTLED' COMMENT 'SETTLED/PENDING/CANCELLED',
  `title`       VARCHAR(128)  DEFAULT NULL COMMENT '流水标题',
  `created_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_courier_created_at` (`courier_id`, `created_at`),
  KEY `idx_task_id` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='骑手收益流水表';
```

设计要点：

- 骑手收益页的总收益、今日收益、完成订单数可从该表聚合
- 完成签收后按任务奖励金额写入一条收益流水
- `status` 预留结算中、已结算、取消等状态，便于后续财务扩展

---

## user_addresses（用户常用地址表）— 10 个字段

*代码块*
```sql
CREATE TABLE `user_addresses` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '地址主键',
  `user_id`     BIGINT       NOT NULL COMMENT '关联 users.id',
  `name`        VARCHAR(64)  NOT NULL COMMENT '联系人',
  `phone`       VARCHAR(20)  NOT NULL COMMENT '联系电话',
  `address`     VARCHAR(255) NOT NULL COMMENT '详细地址',
  `lat`         DECIMAL(10,6) DEFAULT NULL COMMENT '纬度',
  `lng`         DECIMAL(10,6) DEFAULT NULL COMMENT '经度',
  `is_default`  TINYINT      DEFAULT 0 COMMENT '是否默认地址：0=否，1=是',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_default` (`user_id`, `is_default`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户常用地址表';
```

设计要点：

- 个人中心地址管理从该表读取和新增
- `lat` / `lng` 便于后续做地图选址和附近驿站推荐
- 同一用户建议业务层保证最多一个默认地址

---

## user_points_accounts（用户积分账户表）— 8 个字段

*代码块*
```sql
CREATE TABLE `user_points_accounts` (
  `id`                    BIGINT        NOT NULL AUTO_INCREMENT COMMENT '积分账户主键',
  `user_id`               BIGINT        NOT NULL COMMENT '关联 users.id',
  `points`                INT           DEFAULT 0 COMMENT '可用积分',
  `coupon_count`          INT           DEFAULT 0 COMMENT '可用优惠券数量',
  `balance`               DECIMAL(10,2) DEFAULT 0 COMMENT '零钱余额',
  `member_level`          VARCHAR(32)   DEFAULT '普通村民' COMMENT '会员等级',
  `monthly_signed_count`  INT           DEFAULT 0 COMMENT '本月收件签收次数',
  `updated_at`            DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户积分账户表';
```

设计要点：

- 个人中心首页的积分、优惠券数量、余额、会员等级从该表读取
- `monthly_signed_count` 支撑“本月完成 N 次收件签收”的成长体系展示
- 包裹签收成功后可增加积分和签收次数

---

## user_coupons（用户优惠券表）— 11 个字段

*代码块*
```sql
CREATE TABLE `user_coupons` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '优惠券主键',
  `coupon_no`   VARCHAR(32)   NOT NULL COMMENT '优惠券编号',
  `user_id`     BIGINT        NOT NULL COMMENT '关联 users.id',
  `name`        VARCHAR(64)   NOT NULL COMMENT '优惠券名称',
  `amount`      DECIMAL(10,2) DEFAULT 0 COMMENT '优惠金额',
  `status`      VARCHAR(32)   DEFAULT 'AVAILABLE' COMMENT 'AVAILABLE/USED/EXPIRED',
  `source`      VARCHAR(32)   DEFAULT NULL COMMENT '来源：兑换/活动/补偿',
  `expire_time` DATETIME      DEFAULT NULL COMMENT '过期时间',
  `used_at`     DATETIME      DEFAULT NULL COMMENT '使用时间',
  `created_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_coupon_no` (`coupon_no`),
  KEY `idx_user_status` (`user_id`, `status`),
  KEY `idx_expire_time` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户优惠券表';
```

设计要点：

- 优惠券列表和个人中心优惠券数量均依赖该表
- 积分兑换优惠券时会新增优惠券并更新积分账户
- `status` 支撑可用、已使用、已过期筛选

---

## wallet_transactions（钱包流水表）— 9 个字段

*代码块*
```sql
CREATE TABLE `wallet_transactions` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '钱包流水主键',
  `user_id`     BIGINT        NOT NULL COMMENT '关联 users.id',
  `type`        VARCHAR(32)   NOT NULL COMMENT '流水类型：REFUND/REWARD/CONSUME/ADJUST',
  `amount`      DECIMAL(10,2) NOT NULL COMMENT '流水金额，收入为正，支出为负',
  `title`       VARCHAR(128)  NOT NULL COMMENT '流水标题',
  `biz_type`    VARCHAR(32)   DEFAULT NULL COMMENT '关联业务类型',
  `biz_id`      VARCHAR(64)   DEFAULT NULL COMMENT '关联业务ID',
  `created_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_created_at` (`user_id`, `created_at`),
  KEY `idx_biz` (`biz_type`, `biz_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='钱包流水表';
```

设计要点：

- 个人中心零钱流水从该表分页读取
- `amount` 正负值直接表示收入和支出，便于聚合余额变动
- `biz_type` / `biz_id` 方便追溯到退款、活动奖励、人工调整等业务来源

---

## mall_items（积分商城权益表）— 10 个字段

*代码块*
```sql
CREATE TABLE `mall_items` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '权益主键',
  `item_no`     VARCHAR(32)  NOT NULL COMMENT '权益编号',
  `name`        VARCHAR(64)  NOT NULL COMMENT '权益名称',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '权益说明',
  `points`      INT          NOT NULL COMMENT '兑换所需积分',
  `type`        VARCHAR(16)  NOT NULL COMMENT 'coupon/goods',
  `stock`       INT          DEFAULT 0 COMMENT '库存',
  `status`      TINYINT      DEFAULT 1 COMMENT '0=下架，1=上架',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_item_no` (`item_no`),
  KEY `idx_status_type` (`status`, `type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='积分商城权益表';
```

设计要点：

- 积分商城列表由该表提供，类型分为优惠券和实物商品
- 兑换时需要校验 `status=1`、库存充足、用户积分足够
- `stock` 对优惠券类权益可表示可发放总量，对实物类权益表示库存

---

## mall_redeem_records（积分兑换记录表）— 10 个字段

*代码块*
```sql
CREATE TABLE `mall_redeem_records` (
  `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '兑换记录主键',
  `record_no`      VARCHAR(32)  NOT NULL COMMENT '兑换记录编号',
  `user_id`        BIGINT       NOT NULL COMMENT '关联 users.id',
  `item_id`        BIGINT       NOT NULL COMMENT '关联 mall_items.id',
  `item_name`      VARCHAR(64)  NOT NULL COMMENT '兑换时的权益名称快照',
  `points_cost`    INT          NOT NULL COMMENT '消耗积分',
  `remain_points`  INT          NOT NULL COMMENT '兑换后剩余积分',
  `status`         VARCHAR(32)  DEFAULT 'SUCCESS' COMMENT 'SUCCESS/CANCELLED',
  `created_at`     DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`     DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_record_no` (`record_no`),
  KEY `idx_user_created_at` (`user_id`, `created_at`),
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='积分兑换记录表';
```

设计要点：

- 兑换记录页从该表分页读取
- `item_name`、`points_cost` 使用快照字段，避免权益改名或改积分后影响历史记录
- 兑换成功后同步扣减积分账户，必要时生成优惠券或实物领取记录

---

## news_posts（乡镇资讯表）— 12 个字段

*代码块*
```sql
CREATE TABLE `news_posts` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '资讯主键',
  `post_no`     VARCHAR(32)  NOT NULL COMMENT '资讯编号，如 NEWS-001',
  `title`       VARCHAR(128) NOT NULL COMMENT '标题',
  `content`     TEXT         NOT NULL COMMENT '内容',
  `tag`         VARCHAR(32)  DEFAULT NULL COMMENT '标签',
  `author_id`   BIGINT       DEFAULT NULL COMMENT '发布人ID，可关联 users/admins',
  `author_type` VARCHAR(16)  DEFAULT 'ADMIN' COMMENT '发布人类型：USER/ADMIN',
  `station_id`  BIGINT       DEFAULT NULL COMMENT '关联驿站ID',
  `likes`       INT          DEFAULT 0 COMMENT '点赞数',
  `is_urgent`   TINYINT      DEFAULT 0 COMMENT '是否紧急通知',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_post_no` (`post_no`),
  KEY `idx_station_id` (`station_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='乡镇资讯表';
```

设计要点：

- 资讯列表和发布动态都依赖该表
- 发布接口应返回 `NewsPostVO`，移动端用服务端返回数据更新列表
- `is_urgent` 支撑紧急通知样式展示

---

## news_comments（资讯评论表）— 7 个字段

*代码块*
```sql
CREATE TABLE `news_comments` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '评论主键',
  `post_id`     BIGINT       NOT NULL COMMENT '关联 news_posts.id',
  `user_id`     BIGINT       NOT NULL COMMENT '评论用户ID',
  `content`     VARCHAR(255) NOT NULL COMMENT '评论内容',
  `status`      TINYINT      DEFAULT 1 COMMENT '状态：0=隐藏，1=正常',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_post_created_at` (`post_id`, `created_at`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='资讯评论表';
```

设计要点：

- 资讯卡片可以聚合最近几条评论生成 `comments` 摘要
- `status` 支撑评论审核和隐藏
- 点赞数直接保存在 `news_posts.likes`，评论独立存储便于分页

---

## help_items（帮助中心表）— 7 个字段

*代码块*
```sql
CREATE TABLE `help_items` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '帮助条目主键',
  `help_no`     VARCHAR(32)  NOT NULL COMMENT '帮助条目编号',
  `title`       VARCHAR(128) NOT NULL COMMENT '标题',
  `content`     TEXT         NOT NULL COMMENT '内容',
  `sort_order`  INT          DEFAULT 0 COMMENT '排序值，越小越靠前',
  `status`      TINYINT      DEFAULT 1 COMMENT '状态：0=下线，1=上线',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_help_no` (`help_no`),
  KEY `idx_status_sort` (`status`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帮助中心表';
```

设计要点：

- 个人中心帮助中心从该表读取
- `sort_order` 支撑后台调整展示顺序
- 可按 `status` 控制条目上下线

---

## customer_service_configs（客服配置表）— 7 个字段

*代码块*
```sql
CREATE TABLE `customer_service_configs` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '配置主键',
  `phone`         VARCHAR(20)  DEFAULT NULL COMMENT '客服电话',
  `online_time`   VARCHAR(64)  DEFAULT NULL COMMENT '在线时间',
  `wechat`        VARCHAR(64)  DEFAULT NULL COMMENT '客服微信',
  `status`        TINYINT      DEFAULT 1 COMMENT '状态：0=停用，1=启用',
  `created_at`    DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客服配置表';
```

设计要点：

- 个人中心客服入口从启用状态的配置读取
- 当前可全局一份配置，后续如需按驿站配置可增加 `station_id`
- 避免客服电话、在线时间等信息写死在客户端

---

## upload_files（文件上传记录表）— 9 个字段

*代码块*
```sql
CREATE TABLE `upload_files` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '文件主键',
  `file_no`       VARCHAR(32)  NOT NULL COMMENT '文件编号',
  `url`           VARCHAR(512) NOT NULL COMMENT '文件访问路径',
  `name`          VARCHAR(255) NOT NULL COMMENT '原始文件名',
  `size`          BIGINT       DEFAULT 0 COMMENT '文件大小，单位字节',
  `content_type`  VARCHAR(128) DEFAULT NULL COMMENT '文件MIME类型',
  `scene`         VARCHAR(32)  DEFAULT NULL COMMENT '上传场景：AVATAR/COMPLAIN/DELIVER_PROOF',
  `uploader_id`   BIGINT       DEFAULT NULL COMMENT '上传人ID',
  `created_at`    DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_file_no` (`file_no`),
  KEY `idx_scene` (`scene`),
  KEY `idx_uploader_id` (`uploader_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文件上传记录表';
```

设计要点：

- 投诉图片、送达凭证、头像上传统一记录在该表
- `scene` 支撑按业务场景做大小、格式和权限校验
- 业务表只保存文件 URL，文件元信息统一在上传表维护
