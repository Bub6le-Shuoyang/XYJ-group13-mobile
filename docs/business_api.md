# **乡驿家 (XiangYiJia) 服务端 — 核心业务 API 文档草案**

> **全局约定**：
> 1. 所有请求需在 Header 携带 `Authorization: Bearer <token>`
> 2. 所有响应均为 `Result<T>` 格式（包含 `code`, `message`, `data`, `timestamp`）

---

## **一、村民/用户模块 (`UserController`)**
路径前缀：`/api/v1/user/packages`

### **1.1 发起寄件**
*   **Method**: `POST` `/api/v1/user/packages`
*   **说明**: 用户填写包裹信息并发起寄件申请，生成待支付或待入库订单。
*   **请求体**:
    ```json
    {
      "name": "农资工具箱",
      "receiver_name": "王大爷",
      "receiver_phone": "13800001111",
      "address": "清河村 3 组 18 号",
      "weight": 2.5
    }
    ```
*   **响应 Data**: `PackageVO` (包含生成的包裹ID `package_id` 和预估费用 `estimated_fee`)

### **1.2 支付费用**
*   **Method**: `POST` `/api/v1/user/packages/{package_id}/pay`
*   **说明**: 用户支付寄件费用。
*   **请求体**:
    ```json
    {
      "pay_method": "WECHAT_PAY",
      "amount": 10.5
    }
    ```
*   **响应 Data**: `Boolean` (true 表示支付成功)

### **1.3 获取我的收件/寄件列表**
*   **Method**: `GET` `/api/v1/user/packages?type={type}&page=1&size=10`
*   **说明**: `type` 可选值为 `SEND` (我寄出的) 或 `RECEIVE` (寄给我的)。
*   **响应 Data**: `Page<PackageVO>`

### **1.4 确认签收**
*   **Method**: `POST` `/api/v1/user/packages/{package_id}/confirm`
*   **说明**: 用户收到包裹后确认签收，包裹状态变为“已完成”。
*   **响应 Data**: `Boolean`

### **1.5 评价包裹服务**
*   **Method**: `POST` `/api/v1/user/packages/{package_id}/rate`
*   **请求体**:
    ```json
    {
      "score": 5,
      "comment": "配送非常快，态度很好！"
    }
    ```
*   **响应 Data**: `Boolean`

### **1.6 提交投诉**
*   **Method**: `POST` `/api/v1/user/packages/{package_id}/complain`
*   **请求体**:
    ```json
    {
      "reason": "包裹破损",
      "description": "外包装有明显水渍",
      "images": ["/uploads/img1.jpg"]
    }
    ```
*   **响应 Data**: `Boolean`

---

## **二、配送员模块 (`CourierController`)**
路径前缀：`/api/v1/courier`

### **2.1 获取可抢任务列表**
*   **Method**: `GET` `/api/v1/courier/tasks/available?page=1&size=10`
*   **说明**: 获取站点管理员已发布、待抢单的配送任务。
*   **响应 Data**: `Page<TaskVO>`

### **2.2 配送员抢单**
*   **Method**: `POST` `/api/v1/courier/tasks/{task_id}/grab`
*   **说明**: 配送员抢下该任务，任务状态变为“已分配”。
*   **响应 Data**: `Boolean`

### **2.3 确认取件 (前往取件位置)**
*   **Method**: `POST` `/api/v1/courier/tasks/{task_id}/pickup`
*   **说明**: 配送员到达站点或发件人处，扫描/确认已拿到包裹。
*   **响应 Data**: `Boolean`

### **2.4 确认送达 (到达送达位置)**
*   **Method**: `POST` `/api/v1/courier/tasks/{task_id}/deliver`
*   **说明**: 配送员将包裹送达指定地点（驿站或村民家中），等待村民签收。
*   **请求体**:
    ```json
    {
      "deliver_image": "/uploads/proof.jpg"  // 可选：送达拍照凭证
    }
    ```
*   **响应 Data**: `Boolean`

### **2.5 查看收益**
*   **Method**: `GET` `/api/v1/courier/earnings`
*   **说明**: 获取配送员的收益统计信息。
*   **响应 Data**:
    ```json
    {
      "total_earnings": 1250.00,
      "today_earnings": 45.00,
      "completed_orders": 128
    }
    ```

---

## **三、站点管理员模块 (`AdminPackageController`)**
路径前缀：`/api/v1/admin/packages`

### **3.1 包裹入库**
*   **Method**: `POST` `/api/v1/admin/packages/{package_id}/inbound`
*   **说明**: 村民寄出的包裹到达站点，管理员确认入库。
*   **请求体**:
    ```json
    {
      "shelf_number": "A-01-03" // 货架号
    }
    ```
*   **响应 Data**: `Boolean`

### **3.2 包裹出库**
*   **Method**: `POST` `/api/v1/admin/packages/{package_id}/outbound`
*   **说明**: 配送员来站点取件，或者村民直接来站点拿件时，管理员操作出库。
*   **响应 Data**: `Boolean`

### **3.3 发布配送任务**
*   **Method**: `POST` `/api/v1/admin/tasks`
*   **说明**: 将已入库的包裹发布到任务大厅，供配送员抢单。
*   **请求体**:
    ```json
    {
      "package_id": "PKG-001",
      "reward_amount": 8.0  // 配送奖励金额
    }
    ```
*   **响应 Data**: `Boolean`
