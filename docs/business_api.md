# **乡驿家 (XiangYiJia) 服务端 — 核心业务 API 文档**

## **一、全局约定**

### **1.1 基础路径**

所有 RESTful API 以 `/api/v1` 为版本前缀。

### **1.2 统一响应格式**

所有接口返回 `Result<T>` 结构：

*代码块*

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1745784000000
}
```

| 字段        | 类型      | 说明                 |
| --------- | ------- | ------------------ |
| code      | Integer | 状态码，200=成功，其他=业务错误 |
| message   | String  | 提示信息               |
| data      | T       | 业务数据，成功时返回具体对象     |
| timestamp | Long    | 服务端时间戳（毫秒）         |

### **1.3 认证方式**

除登录接口外，所有业务接口均使用 **JWT Token** 认证，通过请求头 `Authorization: Bearer <token>` 传递。

当前移动端只支持账号密码登录，不接入图形验证码、邮箱验证码、短信验证码或第三方登录。

### **1.4 当前业务范围**

当前移动端只支持收件/上门配送业务，不接入寄件主流程。历史寄件接口可保留为后端预留能力，但移动端不展示入口、不主动调用。

### **1.5 参数校验**

所有 `@RequestBody` 参数均使用 `@Validated` 注解触发 Jakarta Validation 校验，校验失败会返回字段级错误信息。

### **1.6 分页响应格式**

列表接口统一返回 `Page<T>`：

*代码块*

```json
{
  "records": [],
  "total": 100,
  "size": 10,
  "current": 1,
  "pages": 10
}
```

| 字段      | 类型       | 说明         |
| ------- | -------- | ---------- |
| records | Array<T> | 当前页数据      |
| total   | Long     | 总条数        |
| size    | Long     | 每页条数       |
| current | Long     | 当前页，从 1 开始 |
| pages   | Long     | 总页数        |

**---**

## **二、接口总览**

| 模块      | Controller             | 接口数 | 路径前缀                    | 移动端是否需要 |
| ------- | ---------------------- | --- | ----------------------- | ------- |
| 统一认证    | AuthController         | 4   | `/api/v1/auth`          | 是       |
| 管理员认证兼容 | AdminAuthController    | 5   | `/api/v1/admin/auth`    | 管理员登录兼容 |
| 管理员资料   | AdminProfileController | 2   | `/api/v1/admin/profile` | 是       |
| 用户管理    | AdminUserController    | 4   | `/api/v1/admin/users`   | 后台管理使用  |
| 用户包裹    | UserPackageController  | 5   | `/api/v1/user/packages` | 是       |
| 用户个人中心  | UserProfileController  | 10  | `/api/v1/user`          | 是       |
| 站点管理员包裹 | AdminPackageController | 5   | `/api/v1/admin`         | 是       |
| 骑手任务    | CourierController      | 8   | `/api/v1/courier`       | 是       |
| 乡镇资讯    | ContentController      | 4   | `/api/v1/content`       | 是       |
| 驿站地图    | StationController      | 2   | `/api/v1/stations`      | 是       |
| 文件上传    | UploadController       | 1   | `/api/v1/upload`        | 是       |

> 另有 `AdminController`（`/admin`）提供页面路由（login、index），返回视图名，非 RESTful API。

**---**

## **三、统一认证模块 (`AuthController`)**

路径前缀：`/api/v1/auth`

### **3.1 账号密码登录**

*代码块*

```
POST /api/v1/auth/login
```

**认证**：无需认证

**说明**：移动端推荐使用该接口统一处理村民、站点管理员、骑手三类角色登录。当前只支持账号密码登录。

**请求体**：`LoginDTO`

*代码块*

```json
{
  "account": "admin@example.com",
  "password": "MyPass123!",
  "role": "ADMIN"
}
```

| 字段       | 类型     | 必填 | 说明                               |
| -------- | ------ | -- | -------------------------------- |
| account  | String | 是  | 登录账号，可为邮箱、手机号或用户名                |
| password | String | 是  | 登录密码                             |
| role     | String | 是  | `VILLAGER` / `ADMIN` / `COURIER` |

**响应 data**：`LoginResponseVO`

*代码块*

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9...",
  "expires_in": 7200,
  "user": {
    "id": 1,
    "user_no": "U20260524001",
    "account": "admin@example.com",
    "email": "admin@example.com",
    "phone": "13800138000",
    "nickname": "站点管理员",
    "avatar_url": "/uploads/avatar.png",
    "role": "ADMIN",
    "is_realname_auth": true
  }
}
```

### **3.2 获取当前登录账号**

*代码块*

```
GET /api/v1/auth/me
```

**认证**：需要 Bearer Token

**响应 data**：`UserVO`

### **3.3 刷新 Token**

*代码块*

```
POST /api/v1/auth/refresh
```

**认证**：无需 Bearer Token

**请求体**：

*代码块*

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**响应 data**：`LoginResponseVO`

### **3.4 退出登录**

*代码块*

```
POST /api/v1/auth/logout
```

**认证**：需要 Bearer Token

**响应 data**：`Boolean`

**---**

## **四、管理员认证兼容模块 (`AdminAuthController`)**

路径前缀：`/api/v1/admin/auth`

> 本模块为后台已实现接口。移动端只需要兼容账号密码登录，不使用图形验证码、邮箱验证码、注册和重置密码流程。

### **4.1 获取图形验证码（后台预留，移动端不使用）**

*代码块*

```
GET /api/v1/admin/auth/captcha
```

**认证**：无需认证

**响应 data**：`CaptchaResponseVO`

### **4.2 发送邮箱验证码（后台预留，移动端不使用）**

*代码块*

```
POST /api/v1/admin/auth/send-email-code
```

**认证**：无需认证

**请求体**：`SendEmailCodeDTO`

**响应 data**：`SendCaptchaResponseVO`

### **4.3 管理员注册（后台预留，移动端不使用）**

*代码块*

```
POST /api/v1/admin/auth/register
```

**认证**：无需认证

**请求体**：`AdminRegisterDTO`

**响应 data**：`LoginResponseVO`

### **4.4 管理员账号密码登录**

*代码块*

```
POST /api/v1/admin/auth/login
```

**认证**：无需认证

**说明**：兼容已实现后台管理员登录接口。移动端管理员登录可以临时使用该接口，但推荐后续统一到 `/api/v1/auth/login`。

**请求体**：`AdminLoginDTO`

*代码块*

```json
{
  "email": "admin@example.com",
  "password": "MyPass123!"
}
```

**响应 data**：`LoginResponseVO`

### **4.5 重置密码（后台预留，移动端不使用）**

*代码块*

```
POST /api/v1/admin/auth/reset-password
```

**认证**：无需认证

**请求体**：`AdminResetPasswordDTO`

**响应 data**：`null`

**---**

## **五、管理员资料模块 (`AdminProfileController`)**

路径前缀：`/api/v1/admin/profile` | **需要认证**

### **5.1 获取当前管理员信息**

*代码块*

```
GET /api/v1/admin/profile
```

**认证**：需要 Bearer Token

**响应 data**：`Admins`（`passwordHash` 字段置空）

### **5.2 更新当前管理员资料**

*代码块*

```
PUT /api/v1/admin/profile
```

**认证**：需要 Bearer Token

**请求体**：`Admins`（部分更新）

*代码块*

```json
{
  "realName": "新姓名",
  "phone": "13900139000",
  "avatarUrl": "/uploads/new_avatar.png"
}
```

**响应 data**：更新后的 `Admins`（`passwordHash` 字段置空）

**---**

## **六、用户包裹模块 (`UserPackageController`)**

路径前缀：`/api/v1/user/packages` | **需要认证**

### **6.1 获取我的收件列表**

*代码块*

```
GET /api/v1/user/packages?type=RECEIVE&page=1&size=10
```

**说明**：当前移动端只传 `RECEIVE`。`SEND` 为历史预留，不作为 App 主流程。

**响应 data**：`Page<PackageVO>`

*代码块*

```json
{
  "records": [
    {
      "package_id": "PKG-003",
      "task_id": "TASK-003",
      "name": "药品快件",
      "receiver_name": "赵奶奶",
      "receiver_phone": "13800001111",
      "address": "清河村卫生室旁",
      "weight": 1.2,
      "estimated_fee": 0,
      "status": "ASSIGNED",
      "pickup_code": "QJ25003",
      "sender_name": "县医院",
      "reward_amount": 12,
      "timeline": ["县医院已发出", "站点完成入库", "张师傅正在送货上门"],
      "courier_name": "张师傅",
      "station_id": "ST-001",
      "station_name": "清河村中心驿站",
      "lat": 30.503,
      "lng": 114.302
    }
  ],
  "total": 1,
  "size": 10,
  "current": 1,
  "pages": 1
}
```

### **6.2 获取包裹详情**

*代码块*

```
GET /api/v1/user/packages/{package_id}
```

**响应 data**：`PackageVO`

### **6.3 用户确认签收**

*代码块*

```
POST /api/v1/user/packages/{package_id}/confirm
```

**说明**：用于用户主动确认签收场景。骑手上门核验取件码完成签收应使用 `POST /api/v1/courier/tasks/{task_id}/verify-pickup-code`。

**响应 data**：`Boolean`

### **6.4 评价包裹服务**

*代码块*

```
POST /api/v1/user/packages/{package_id}/rate
```

**请求体**：

*代码块*

```json
{
  "score": 5,
  "comment": "配送非常快，态度很好！"
}
```

**响应 data**：`Boolean`

### **6.5 提交投诉**

*代码块*

```
POST /api/v1/user/packages/{package_id}/complain
```

**请求体**：

*代码块*

```json
{
  "reason": "包裹破损",
  "description": "外包装有明显水渍",
  "images": ["/uploads/img1.jpg"]
}
```

**响应 data**：`Boolean`

**---**

## **七、用户个人中心模块 (`UserProfileController`)**

路径前缀：`/api/v1/user` | **需要认证**

### **7.1 获取用户资料首页**

*代码块*

```
GET /api/v1/user/profile
```

**说明**：返回个人中心首页聚合数据，保证移动端首屏一次请求可展示。

**响应 data**：`UserProfileVO`

### **7.2 获取常用地址列表**

*代码块*

```
GET /api/v1/user/addresses
```

**响应 data**：`List<AddressVO>`

### **7.3 新增常用地址**

*代码块*

```
POST /api/v1/user/addresses
```

**请求体**：

*代码块*

```json
{
  "name": "张三",
  "phone": "13800001111",
  "address": "清河村 5 组 9 号",
  "is_default": false
}
```

**响应 data**：`AddressVO`

### **7.4 获取优惠券列表**

*代码块*

```
GET /api/v1/user/coupons?status=AVAILABLE&page=1&size=10
```

**响应 data**：`Page<CouponVO>`

### **7.5 获取钱包流水**

*代码块*

```
GET /api/v1/user/wallet/transactions?page=1&size=10
```

**响应 data**：`Page<WalletTransactionVO>`

### **7.6 获取积分商城权益**

*代码块*

```
GET /api/v1/user/mall/items?page=1&size=20
```

**响应 data**：`Page<MallItemVO>`

### **7.7 兑换积分商城权益**

*代码块*

```
POST /api/v1/user/mall/items/{item_id}/redeem
```

**响应 data**：`RedeemRecordVO`

### **7.8 获取兑换记录**

*代码块*

```
GET /api/v1/user/mall/redeem-records?page=1&size=10
```

**响应 data**：`Page<RedeemRecordVO>`

### **7.9 获取帮助中心**

*代码块*

```
GET /api/v1/user/help-center
```

**响应 data**：`List<HelpItemVO>`

### **7.10 获取客服信息**

*代码块*

```
GET /api/v1/user/customer-service
```

**响应 data**：`CustomerServiceVO`

**---**

## **八、站点管理员包裹模块 (`AdminPackageController`)**

路径前缀：`/api/v1/admin` | **需要认证，角色 ADMIN**

### **8.1 获取站点包裹列表**

*代码块*

```
GET /api/v1/admin/packages?status=IN_STOCK&page=1&size=100
```

**说明**：管理员工作台按状态筛选待入库、待出库、派送中、已完成包裹。管理员不能复用用户包裹列表。

**响应 data**：`Page<PackageVO>`

### **8.2 包裹入库**

*代码块*

```
POST /api/v1/admin/packages/{package_id}/inbound
```

**请求体**：

*代码块*

```json
{
  "shelf_number": "A-01-03"
}
```

**响应 data**：`Boolean`

**状态流转**：`PENDING_INBOUND -> IN_STOCK`

### **8.3 包裹出库**

*代码块*

```
POST /api/v1/admin/packages/{package_id}/outbound
```

**响应 data**：`Boolean`

### **8.4 发布配送任务**

*代码块*

```
POST /api/v1/admin/tasks
```

**请求体**：

*代码块*

```json
{
  "package_id": "PKG-001",
  "reward_amount": 8.0
}
```

**响应 data**：`TaskVO`

**说明**：发布成功后必须返回 `task_id`，后续骑手抢单、取件、核验取件码均使用 `task_id`。

**状态流转**：`IN_STOCK -> TASK_PUBLISHED`

### **8.5 获取站点统计**

*代码块*

```
GET /api/v1/admin/station/statistics
```

**响应 data**：`StationStatisticsVO`

**---**

## **九、骑手任务模块 (`CourierController`)**

路径前缀：`/api/v1/courier` | **需要认证，角色 COURIER**

### **9.1 获取可抢任务列表**

*代码块*

```
GET /api/v1/courier/tasks/available?page=1&size=10
```

**说明**：获取站点管理员已发布、待抢单的配送任务。骑手不能复用用户包裹列表。

**响应 data**：`Page<TaskVO>`

### **9.2 获取我的配送任务**

*代码块*

```
GET /api/v1/courier/tasks/mine?status=ASSIGNED&page=1&size=10
```

**响应 data**：`Page<TaskVO>`

### **9.3 配送员抢单**

*代码块*

```
POST /api/v1/courier/tasks/{task_id}/grab
```

**说明**：必须使用 `TaskVO.task_id`，不能使用 `package_id`。

**响应 data**：`TaskVO`

**状态流转**：`TASK_PUBLISHED -> ASSIGNED`

### **9.4 确认取件**

*代码块*

```
POST /api/v1/courier/tasks/{task_id}/pickup
```

**响应 data**：`TaskVO`

**状态流转**：`ASSIGNED -> DELIVERING`

### **9.5 上传送达凭证**

*代码块*

```
POST /api/v1/courier/tasks/{task_id}/deliver
```

**请求体**：

*代码块*

```json
{
  "deliver_image": "/uploads/proof.jpg",
  "remark": "已到达村民家门口"
}
```

**响应 data**：`TaskVO`

### **9.6 核验取件码并完成签收**

*代码块*

```
POST /api/v1/courier/tasks/{task_id}/verify-pickup-code
```

**说明**：骑手上门后向用户索要取件码，核验成功后完成订单。该接口是当前移动端主签收动作。

**请求体**：

*代码块*

```json
{
  "pickup_code": "QJ25003"
}
```

**响应 data**：`TaskVO`

**状态流转**：`ASSIGNED/DELIVERING -> COMPLETED`，并同步 `packages.status -> COMPLETED`

### **9.7 查看收益**

*代码块*

```
GET /api/v1/courier/earnings
```

**响应 data**：`EarningsVO`

### **9.8 获取配送员资料**

*代码块*

```
GET /api/v1/courier/profile
```

**响应 data**：`CourierProfileVO`

**---**

## **十、乡镇资讯模块 (`ContentController`)**

路径前缀：`/api/v1/content` | **需要认证**

### **10.1 获取乡镇资讯**

*代码块*

```
GET /api/v1/content/news?page=1&size=20
```

**响应 data**：`Page<NewsPostVO>`

### **10.2 发布乡镇资讯**

*代码块*

```
POST /api/v1/content/news
```

**请求体**：

*代码块*

```json
{
  "title": "生鲜包裹优先配送",
  "content": "今天驿站生鲜包裹优先配送",
  "tag": "驿站动态",
  "is_urgent": false
}
```

**响应 data**：`NewsPostVO`

**说明**：发布成功后移动端应使用服务端返回的 `NewsPostVO` 更新列表。

### **10.3 点赞资讯**

*代码块*

```
POST /api/v1/content/news/{news_id}/like
```

**响应 data**：`Boolean`

### **10.4 评论资讯**

*代码块*

```
POST /api/v1/content/news/{news_id}/comments
```

**请求体**：

*代码块*

```json
{
  "content": "收到，谢谢提醒"
}
```

**响应 data**：`CommentVO`

**---**

## **十一、驿站地图模块 (`StationController`)**

路径前缀：`/api/v1/stations` | **需要认证**

### **11.1 获取附近驿站**

*代码块*

```
GET /api/v1/stations/nearby?lat=30.51&lng=114.31
```

**响应 data**：`List<StationVO>`

### **11.2 获取驿站详情**

*代码块*

```
GET /api/v1/stations/{station_id}
```

**响应 data**：`StationVO`

**---**

## **十二、文件上传模块 (`UploadController`)**

路径前缀：`/api/v1/upload` | **需要认证**

### **12.1 上传文件**

*代码块*

```
POST /api/v1/upload
```

**请求格式**：`multipart/form-data`

| 字段    | 类型            | 必填 | 说明                                      |
| ----- | ------------- | -- | --------------------------------------- |
| file  | MultipartFile | 是  | 文件内容                                    |
| scene | String        | 否  | `AVATAR` / `COMPLAIN` / `DELIVER_PROOF` |

**响应 data**：`UploadVO`

**---**

## **十三、后台用户管理模块 (`AdminUserController`)**

路径前缀：`/api/v1/admin/users` | **需要认证**

### **13.1 用户列表（分页+搜索）**

*代码块*

```
GET /api/v1/admin/users?page=1&size=10&keyword=xxx
```

**响应 data**：`Page<UserListVO>`

### **13.2 创建用户**

*代码块*

```
POST /api/v1/admin/users
```

**请求体**：`CreateUserDTO`

**响应 data**：创建后的 `Users` 对象（`passwordHash` 字段置空）

### **13.3 更新用户**

*代码块*

```
PUT /api/v1/admin/users/{id}
```

**请求体**：`Users` 实体

**响应 data**：更新后的 `Users` 对象

### **13.4 删除用户**

*代码块*

```
DELETE /api/v1/admin/users/{id}
```

**响应 data**：`null`

**---**

## **十四、核心 VO/DTO 字段定义**

### **14.1 LoginResponseVO**

| 字段             | 类型     | 说明            |
| -------------- | ------ | ------------- |
| token          | String | JWT 访问令牌      |
| refresh\_token | String | 刷新令牌          |
| expires\_in    | Long   | Token 有效期，单位秒 |
| user           | UserVO | 当前登录账号        |

### **14.2 UserVO**

| 字段                 | 类型      | 说明                               |
| ------------------ | ------- | -------------------------------- |
| id                 | Long    | 用户 ID                            |
| user\_no           | String  | 用户业务编号，管理员可为空                    |
| account            | String  | 登录账号                             |
| email              | String  | 邮箱                               |
| phone              | String  | 手机号                              |
| nickname           | String  | 昵称或真实姓名                          |
| avatar\_url        | String  | 头像地址                             |
| role               | String  | `VILLAGER` / `ADMIN` / `COURIER` |
| is\_realname\_auth | Boolean | 是否实名                             |

### **14.3 PackageVO**

| 字段              | 类型            | 说明                 |
| --------------- | ------------- | ------------------ |
| package\_id     | String        | 包裹业务编号             |
| task\_id        | String        | 当前关联任务编号，未发布任务时可为空 |
| name            | String        | 包裹名称               |
| receiver\_name  | String        | 收件人                |
| receiver\_phone | String        | 收件电话               |
| address         | String        | 配送地址               |
| weight          | Double        | 重量                 |
| estimated\_fee  | Double        | 预估费用，收件业务可为 0      |
| status          | String        | 包裹状态               |
| pickup\_code    | String        | 取件码，仅收件人和执行骑手可见    |
| sender\_name    | String        | 来源方                |
| reward\_amount  | Double        | 骑手奖励               |
| timeline        | Array<String> | 流转记录               |
| courier\_name   | String        | 当前骑手名称             |
| station\_id     | String        | 所属驿站 ID            |
| station\_name   | String        | 所属驿站名称             |
| lat             | Double        | 配送纬度               |
| lng             | Double        | 配送经度               |

### **14.4 TaskVO**

| 字段                   | 类型     | 说明                                                    |
| -------------------- | ------ | ----------------------------------------------------- |
| task\_id             | String | 任务编号，骑手接口必须使用该 ID                                     |
| package\_id          | String | 包裹编号                                                  |
| package\_name        | String | 包裹名称                                                  |
| pickup\_address      | String | 取件地址，通常为驿站地址                                          |
| deliver\_address     | String | 送达地址                                                  |
| reward\_amount       | Double | 配送奖励                                                  |
| status               | String | `AVAILABLE` / `ASSIGNED` / `DELIVERING` / `COMPLETED` |
| pickup\_code\_masked | String | 脱敏取件码，可选                                              |
| created\_at          | String | 创建时间                                                  |
| completed\_at        | String | 完成时间，可选                                               |

**---**

## **十五、移动端功能与接口映射**

| 移动端功能   | 必需接口                                                               | 衔接说明                                       |
| ------- | ------------------------------------------------------------------ | ------------------------------------------ |
| 账号密码登录  | `POST /auth/login` 或 `POST /admin/auth/login`                      | 当前仅支持账号密码，不接入验证码和第三方登录                     |
| 村民首页包裹  | `GET /user/packages?type=RECEIVE`                                  | 展示待入库、已入库、派送中、已完成包裹                        |
| 管理员工作台  | `GET /admin/packages`                                              | 管理员不能复用用户包裹列表                              |
| 管理员入库   | `POST /admin/packages/{package_id}/inbound`                        | `PENDING_INBOUND -> IN_STOCK`              |
| 管理员发布配送 | `POST /admin/packages/{package_id}/outbound` + `POST /admin/tasks` | `IN_STOCK -> TASK_PUBLISHED` 并生成 `task_id` |
| 骑手任务大厅  | `GET /courier/tasks/available`                                     | 骑手不能复用用户包裹列表                               |
| 骑手抢单    | `POST /courier/tasks/{task_id}/grab`                               | 必须使用 `task_id`，不能使用 `package_id`           |
| 骑手核验签收  | `POST /courier/tasks/{task_id}/verify-pickup-code`                 | 骑手核验用户取件码，完成签收                             |
| 个人中心    | `GET /user/profile`                                                | 聚合资料、积分、地址、订单摘要、商城入口                       |
| 积分商城    | `GET /user/mall/items`、`POST /user/mall/items/{item_id}/redeem`    | 兑换后返回剩余积分和兑换记录                             |
| 资讯广场    | `GET /content/news`、`POST /content/news`                           | 发布成功后应使用服务端返回的 `NewsPostVO`                |
| 附近驿站    | `GET /stations/nearby`                                             | 地图 Marker 和底部列表来自服务端                       |

**---**

## **十六、移动端降级策略**

- 所有接口仍遵循 `Result<T>` 响应结构。
- 移动端会先请求服务端数据，接口异常、非 `code=200` 或解析失败时，自动使用内置模拟数据。
- 模拟数据中的包裹、用户、骑手、驿站、资讯、积分商城互相关联，保证无服务端时也能完整演示“入库 -> 出库发布任务 -> 骑手抢单 -> 上门核验取件码 -> 签收”链路。

