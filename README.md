# LinServer880

Lineage 私服遊戲伺服器專案（Java 21），包含遊戲核心、資料表、地圖與工具腳本。

本次版本已完成 UTF-8 收斂：核心讀取邏輯、設定檔與基線 SQL 同步到 UTF-8 流程，並提供可回滾的資料庫 migration。

## 專案目標

- 提供可維運的 Lineage 遊戲伺服器核心。
- 支援傳統 Socket 與可切換的 Netty 網路層。
- 提供可重建的資料庫基線與遷移腳本。
- 降低多編碼（Big5/UTF-8）混用造成的亂碼與維護成本。

## 技術與環境

- Java: 21
- Database: MariaDB / MySQL 相容
- Build: Windows Batch（`BuildServer_NoObf.bat`、`BuildServer_Obf.bat`）
- Runtime: `ServerStart.bat` 啟動 `Server_Game.jar`
- Logging: Lombok `1.18.44` + SLF4J + reload4j（沿用 `config/log4j.properties`，建置腳本固定使用/驗證 JDK21 編譯鏈）

## 主要目錄

- `src/`: 遊戲伺服器 Java 原始碼
- `config/`: 伺服器設定（含語系與編碼）
- `database/`: 基線 SQL 與 migration
- `data/`, `maps/`, `skills/`, `img/`: 遊戲資料
- `jar/`: 依賴套件
- `tools/`: 開發與維護工具

## UTF-8 收斂重點（2026-04-03）

### 1) 設定層

- `config/server.properties`
  - 新增 `ClientEncoding = UTF8`
  - 在繁中語系（`ClientLanguage = 3`）下，明確使用 UTF-8。

- `src/com/lineage/config/Config.java`
  - 語系編碼陣列中的繁中項改為 UTF-8。
  - 增加 `ClientLanguage` 邊界保護，避免索引越界。
  - 支援從 `ClientEncoding` 讀取覆寫值，空值時回退到語系預設編碼。

### 2) 讀表層（de_* datatables）

以下檔案移除 Big5 後備欄位讀取，改為只讀 UTF-8 主欄位：

- `src/com/lineage/server/datatables/DeClanTable.java`
- `src/com/lineage/server/datatables/DeNameTable.java`
- `src/com/lineage/server/datatables/DeShopChatTable.java`
- `src/com/lineage/server/datatables/DeGlobalChatTable.java`
- `src/com/lineage/server/datatables/DeTitleTable.java`

### 3) 資料庫層

- `database/880_new.sql`
  - 移除 `de_*` 區塊中的 `*_big5` 欄位。
  - 同步調整 INSERT 欄位數，確保與新欄位結構一致。
  - 正規化為 UTF-8（無 BOM）。

- 新增 migration：
  - `database/migrations/20260403_utf8_drop_big5_columns.sql`
  - `database/migrations/20260403_utf8_drop_big5_columns_rollback.sql`

## Migration 執行建議

1. 先備份資料庫。
2. 在目標 DB 執行：
   - `database/migrations/20260403_utf8_drop_big5_columns.sql`
3. 驗證伺服器啟動與遊戲內顯示字串正常。
4. 若需還原，執行：
   - `database/migrations/20260403_utf8_drop_big5_columns_rollback.sql`

## 建置與啟動

### 建置（不混淆）

在專案根目錄執行：

```bat
BuildServer_NoObf.bat
```

### 建置（混淆）

```bat
BuildServer_Obf.bat
```

### 啟動

```bat
ServerStart.bat
```

## 維運注意事項

- 優先維持 UTF-8 單一流程，避免新增 `*_big5` 雙軌資料。
- 若調整 `de_*` 表結構，請同步檢查 datatable 載入邏輯。
- 提交前建議掃描關鍵字（`big5`, `ms950`）避免回歸。

## 變更檔案（本次 UTF-8 收斂）

- `config/server.properties`
- `database/880_new.sql`
- `database/migrations/20260403_utf8_drop_big5_columns.sql`
- `database/migrations/20260403_utf8_drop_big5_columns_rollback.sql`
- `src/com/lineage/config/Config.java`
- `src/com/lineage/server/datatables/DeClanTable.java`
- `src/com/lineage/server/datatables/DeGlobalChatTable.java`
- `src/com/lineage/server/datatables/DeNameTable.java`
- `src/com/lineage/server/datatables/DeShopChatTable.java`
- `src/com/lineage/server/datatables/DeTitleTable.java`

## Commit 說明紀錄

以下為近期主要 commit 的用途說明，便於追蹤本專案改動脈絡。

- `524e0f6` - `chore: rename project root to LinServer880`
  - 專案根目錄命名整理，統一工作路徑與建置目錄。
- `666fc59` - `fix: add recovered quest classes to runtime classpath`
  - 修復任務類別遺失造成的執行期 classpath 問題。
- `813df51` - `chore: sync current baseline before utf8 migration`
  - 在 UTF-8 遷移前同步基線，降低後續衝突風險。
- `b6d7cb9` - `chore: enforce utf8-only build and convert last legacy java`
  - 建置流程收斂為 UTF-8，並完成最後一批 legacy Java 轉換。
- `456e373` - `refactor: use client language charset in C_Shop`
  - 商店封包改為依語系編碼處理，提升跨語系相容性。
- `3fcd66a` - `refactor: prefer utf8 fields with big5 fallback in de tables`
  - de_* 讀表邏輯優先 UTF-8，保留 Big5 fallback 過渡行為。
- `30b1a76` - `chore: add utf8 backfill and rollback sql scripts`
  - 加入 UTF-8 回填與回滾 SQL，確保遷移可逆。
- `9c795d5` - `feat: finalize UTF-8 migration and add project README`
  - 完成 UTF-8 收尾（設定、讀表、資料庫基線）並新增 README。
- `008ef25` - `chore: ignore IDEA workspace file and stop tracking workspace.xml`
  - 將 IDE 工作區檔從版控中移除，避免本機設定污染提交。
- `d8cdab8` - `build: enable lombok annotation processing in batch builds`
  - 在 NoObf/Obf 建置腳本加入 Lombok 註解處理能力。
- `本次分階段提交(1)` - `refactor: migrate project logging to lombok @Slf4j`
  - 全案將 `apache commons logging` 與 `java.util.logging` 收斂到 `@Slf4j`。
  - 只調整 log print 與 logger 宣告，不更動業務邏輯。
- `本次分階段提交(2)` - `docs: update README with logging migration notes`
  - 補充 Lombok/@Slf4j 導入脈絡與本次 commit 說明。
- `本次獨立提交` - `chore: remove decompiler footer comments across src`
  - 清理 src 內反編譯尾註解（Location / Qualified Name / JD-Core）。
  - 僅移除註解，不調整業務邏輯，並已重新建置驗證可正常打包。
