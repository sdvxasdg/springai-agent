# 智能招聘 Agent 系统

基于 **Spring AI + DashScope（通义千问）** 的智能招聘助手：上传简历自动向量化入库，支持 RAG 检索问答、Tool Calling 查询业务数据、多轮对话与 SSE 流式输出。

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.5-green)
![Spring AI](https://img.shields.io/badge/Spring%20AI-1.1.2-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## ✨ 功能特性

| 功能 | 说明 |
| --- | --- |
| 📄 简历上传 | 支持 PDF / Word / TXT 解析，文本切分后写入 PgVector 向量库 |
| 🔍 RAG 问答 | 检索简历片段注入 Prompt，回答附带来源引用 |
| 🛠 Tool Calling | 岗位查询、投递记录、候选人筛选、面试安排 4 个工具，由模型自主决策调用 |
| 💬 多轮对话 | 基于 Redis List 持久化会话历史，支持 `conversationId` 隔离多会话 |
| 🌊 流式输出 | SSE 事件流，事件类型 `message` / `done` / `error` / `ping` |
| 📊 可观测性 | Actuator 健康检查 + 自定义 RAG / 工具调用统计接口 |
| 📚 接口文档 | Knife4j（OpenAPI 3）在线调试 |

## 🧱 技术栈

- **语言/框架**：Java 17、Spring Boot 3.2.5、Spring AI 1.1.2
- **大模型**：Spring AI Alibaba + DashScope，默认模型 `qwen-plus`
- **数据存储**：
  - MySQL 8 + MyBatis-Plus 3.5.7 —— 候选人、岗位、投递、面试等业务数据
  - PostgreSQL + PgVector —— 简历向量持久化存储
  - Redis —— 会话记忆（ChatMemory）
- **文档解析**：Apache PDFBox 3.0、Apache POI 5.2
- **工程化**：Docker / Docker Compose、Knife4j、统一响应 `Result<T>`、全局异常处理

## 🏗 架构

```
Client
  │
  ▼
Controller ── /ai/chat、/ai/chat/stream、/resume/upload
  │
  ▼
Service / ChatClient
  ├── ChatClient（DashScope 大模型）
  ├── VectorStore（PgVector，RAG 检索）
  └── Tools（4 个 @Tool 业务工具）
  │
  ▼
外部资源：DashScope API ｜ MySQL ｜ PgVector ｜ Redis
```

**混合决策**：模型会自主判断问题应该走 RAG 检索（简历内容）还是调用工具（业务数据查询），二者可组合使用。

## 🚀 快速开始

### 1. 环境要求

- JDK 17+
- Maven 3.8+（或使用自带的 `mvnw`）
- Docker Desktop（用于一键启动 MySQL / Redis / PgVector）

### 2. 启动依赖服务

```bash
docker compose up -d mysql redis pgvector
```

### 3. 配置密钥

项目**不在仓库中存放任何真实密钥**。复制模板并填入你自己的值：

```bash
cp src/main/resources/application-local.yml.example src/main/resources/application-local.yml
```

`application-local.yml` 已被 `.gitignore` 忽略，填写内容示例：

```yaml
spring:
  ai:
    dashscope:
      api-key: sk-你的 DashScope Key
  pgvector:
    datasource:
      password: postgres
  datasource:
    password: root
  data:
    redis:
      password: "123"
```

也可以改用环境变量，主配置已支持占位符覆盖：

| 环境变量 | 说明 | 默认值 |
| --- | --- | --- |
| `DASHSCOPE_API_KEY` | 阿里云百炼 API Key | 无（必填） |
| `MYSQL_HOST` / `MYSQL_USER` / `MYSQL_PASSWORD` | MySQL 连接 | `localhost` / `root` / `root` |
| `PGVECTOR_HOST` / `PGVECTOR_USER` / `PGVECTOR_PASSWORD` | PgVector 连接 | `localhost` / `postgres` / `postgres` |
| `REDIS_HOST` / `REDIS_PASSWORD` | Redis 连接 | `localhost` / `123` |

### 4. 运行

```bash
./mvnw spring-boot:run
# 或
java -jar target/springaiproject_1-0.0.1-SNAPSHOT.jar
```

启动后访问：

- 接口文档：<http://localhost:8899/doc.html>
- 健康检查：<http://localhost:8899/actuator/health>

### 5. 全量容器化（可选）

```bash
docker compose up -d --build
```

## 📡 API 示例

### 上传简历

```bash
curl -X POST http://localhost:8899/resume/upload \
  -F "file=@简历-张三.txt" \
  -F "name=张三"
```

### 对话（一次性返回）

```bash
curl "http://localhost:8899/ai/chat?msg=帮我找会Java的候选人&conversationId=demo-1"
```

### 对话（SSE 流式）

```bash
curl -N "http://localhost:8899/ai/chat/stream?msg=张三是谁&conversationId=demo-1"
```

### 监控统计

```bash
curl http://localhost:8899/ai/stats          # RAG 检索统计
curl http://localhost:8899/ai/tool-stats     # 工具调用统计
curl -X POST http://localhost:8899/ai/tool-stats/reset
```

## 🧩 内置工具（Tool Calling）

| 工具 | 作用 |
| --- | --- |
| `JobQueryTools` | 按岗位名称查询岗位详情与要求 |
| `ApplicationQueryTools` | 按候选人姓名查询投递岗位及当前状态 |
| `ScreenCandidateTools` | 按关键词（技能、经历）筛选候选人 |
| `SendInterviewTools` | 为候选人安排面试（候选人 ID + 岗位 ID + 时间） |

## 📁 项目结构

```
src/main/java/com/atguigo/springaiproject_1
├── common/       统一响应 Result、业务异常、全局异常处理
├── config/       AI、Redis ChatMemory、PgVector、缓存、Knife4j 配置
├── controller/   ChatController（对话/统计）、ResumeController（上传）
├── entity/       Candidate、Job、ApplicationRecord、Interview
├── mapper/       MyBatis-Plus Mapper
├── metrics/      RAG 指标统计
├── service/      文件解析、向量库写入
└── tools/        4 个 @Tool 业务工具
src/main/resources
├── application.yml      主配置（无密钥，全部走占位符）
├── schema.sql           MySQL 建表脚本（启动自动执行）
└── *.txt                RAG 示例简历语料
```

## ⚠️ 安全说明

- 仓库内所有密钥均已替换为环境变量占位符，真实值只存在于本地 `application-local.yml`（已忽略）。
- 生产环境请使用密钥管理服务（如 Nacos、Vault、K8s Secret），不要提交到任何仓库。
- `docker-compose.yml` 中的密码仅用于本地开发演示，切勿用于线上。

## 📄 License

MIT
