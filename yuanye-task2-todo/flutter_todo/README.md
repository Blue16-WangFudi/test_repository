# Flutter Todo List

一个使用 Material UI 编写的 Flutter Todo List 前端项目，调用 SpringBoot 后端接口：

```text
http://localhost:8080/api/todos
```

## 功能

- 查看 Todo 列表
- 新增 Todo
- 删除 Todo
- 切换完成状态
- Widget Test
- integration_test

## 后端接口约定

前端默认使用以下 REST 接口：

- `GET /api/todos`：返回 Todo 数组
- `POST /api/todos`：创建 Todo，请求体 `{"title":"...","completed":false}`
- `PUT /api/todos/{id}`：更新 Todo
- `DELETE /api/todos/{id}`：删除 Todo

Todo JSON 字段：

```json
{
  "id": 1,
  "title": "示例 Todo",
  "completed": false
}
```

## 常用命令

检查 Flutter 环境：

```bash
flutter doctor
```

运行项目：

```bash
flutter run
```

运行测试：

```bash
flutter test
```

构建 Android APK：

```bash
flutter build apk
```

运行 integration_test：

```bash
flutter test integration_test
```
