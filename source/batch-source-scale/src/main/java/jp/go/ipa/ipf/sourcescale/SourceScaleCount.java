/**
 *   <Quantitative project management tool.>
 *   Copyright (C) 2012 IPA, Japan.
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package jp.go.ipa.ipf.sourcescale;

import java.io.File;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Properties;
import java.util.ResourceBundle;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jp.go.ipa.ipf.sourcescale.counter.IpfDefaultSourceScaleCounterImpl;
import jp.go.ipa.ipf.sourcescale.counter.IpfSourceScaleCounter;
import jp.go.ipa.ipf.sourcescale.dao.redmine.RedmineRepositoriesDAO;
import jp.go.ipa.ipf.sourcescale.dao.trac.TracSystemDAO;
import jp.go.ipa.ipf.sourcescale.exception.IpfSQLNormalException;
import jp.go.ipa.ipf.sourcescale.utils.IPFTracUtils;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;
import org.apache.commons.lang.time.DateFormatUtils;
import org.apache.commons.lang.time.DateUtils;
import org.apache.log4j.Logger;
import org.seasar.framework.container.S2Container;
import org.seasar.framework.container.factory.S2ContainerFactory;

/**
 * 版管理ツールからソースファイルを取得してソース規模データ収集を行う抽象クラス。
 * 
 */
public abstract class SourceScaleCount {
    
    /** ロガー名 */
    public final static String LOGGER_NAME = "SourceScaleLogger";
    
    /** ロガー */
    protected static Logger log = Logger.getLogger(LOGGER_NAME);
    
    /** リソース */
    public static ResourceBundle resource = ResourceBundle.getBundle(SourceScaleCount.class.getSimpleName());
    
    /** Trac プロジェクトルートパス を格納する環境変数名 */
    public final static String SYSTEM_ENV_TRAC_PROJECT_ROOT = "TRAC_PROJECT_ROOT";
    
    /** Pentaho設定ファイルのパスを格納する環境変数名 */
    public final static String SYSTEM_ENV_KETTLE_PROP_FILE = "KETTLE_PROP_FILE";
    
    /** Pentaho設定ファイル - IPF・DB ホスト名 のキー */
    public final static String KETTLE_PROP_IPF_DB_HOST   = "IPF_DB_HOST";
    /** Pentaho設定ファイル - IPF・DB ポート番号 のキー */
    public final static String KETTLE_PROP_IPF_DB_PORT   = "IPF_DB_PORT";
    /** Pentaho設定ファイル - IPF・DB データベース名 のキー */
    public final static String KETTLE_PROP_IPF_DB_NAME   = "IPF_DB_NAME";
    /** Pentaho設定ファイル - IPF・DB ユーザ名 のキー */
    public final static String KETTLE_PROP_IPF_DB_USER   = "IPF_DB_USER";
    /** Pentaho設定ファイル - IPF・DB パスワード のキー */
    public final static String KETTLE_PROP_IPF_DB_PASS   = "IPF_DB_PASS";
    /** Pentaho設定ファイル - IPF・DB スキーマ名 のキー */
    public final static String KETTLE_PROP_IPF_DB_SCHEMA = "IPF_DB_SCHEMA";
    
    /** Pentaho設定ファイル - Redmine・DB ホスト名 のキー */
    public final static String KETTLE_PROP_RM_DB_HOST   = "RM_DB_HOST";
    /** Pentaho設定ファイル - Redmine・DB ポート番号 のキー */
    public final static String KETTLE_PROP_RM_DB_PORT   = "RM_DB_PORT";
    /** Pentaho設定ファイル - Redmine・DB データベース名 のキー */
    public final static String KETTLE_PROP_RM_DB_NAME   = "RM_DB_NAME";
    /** Pentaho設定ファイル - Redmine・DB ユーザ名 のキー */
    public final static String KETTLE_PROP_RM_DB_USER   = "RM_DB_USER";
    /** Pentaho設定ファイル - Redmine・DB パスワード のキー */
    public final static String KETTLE_PROP_RM_DB_PASS   = "RM_DB_PASS";
    /** Pentaho設定ファイル - Redmine・DB スキーマ名 のキー */
    public final static String KETTLE_PROP_RM_DB_SCHEMA = "RM_DB_SCHEMA";
    
    /** SQL STATE - キー重複 */
    public final static String SQL_STATE_KEY_DUPLICATE = "23505";
    
    /** デフォルトステップカウンタ */
    protected static IpfSourceScaleCounter defaultSourceScaleCounter;
    
    /** カスタムステップカウンタ登録用マップ */
    protected static Map<String, IpfSourceScaleCounter> customSourceScaleCounterMap = 
            new HashMap<String, IpfSourceScaleCounter>();
    
    // 設定ファイルのPath
    protected static final String PATH = "SourceScaleCount.dicon";
    
    static {
        
        try {
            S2Container container = S2ContainerFactory.create(PATH);
            container.init();
            
            // カスタムステップカウンターを取得してマップに登録
            // カスタムステップカウンタークラスはパッケージ jp.go.ipa.sourcescale.counter.custom 配下に、
            // IpfStepCounter クラスを継承して作成する。
            for (int i = 0; i < container.getComponentDefSize(); i++) {
                
                Object component = container.getComponentDef(i).getComponent();
                if (component instanceof IpfSourceScaleCounter) {
                    // カスタムステップカウンタークラスの場合
                    IpfSourceScaleCounter sourceScaleCounter = (IpfSourceScaleCounter) component;
                    
                    for (String ext : sourceScaleCounter.getFileExtList()) {
                        String regExt = getRegExt(ext);
                        if (regExt != null) {
                            // 対応する拡張子をキーにしてマップに登録
                            customSourceScaleCounterMap.put(regExt, sourceScaleCounter);
                            log.debug(String.format("Custom Counter Loaded : [.%s] : %s",
                                    regExt, sourceScaleCounter.getClass().getName()));
                        }
                    }
                }
            }
        } catch (Exception e) {
            String msg = resource.getString("error.load.custom.counter");
            log.error(msg, e);
        }
        
        // デフォルトのステップカウンタークラス(DefaultIpfStepCounterImpl)を取得
        defaultSourceScaleCounter = new IpfDefaultSourceScaleCounterImpl();
    }
    
    /**
     * ソース規模を収集し結果を返す。
     * 
     * @param oldFile 変更前ファイル
     * @param newFile 変更後ファイル
     * @return ソース規模収集結果
     */
    public static SourceScaleResult count(File oldFile, File newFile) {
        
        String filename = null;
        if (newFile != null) {
            filename = newFile.getName();
        }
        if (oldFile != null) {
            filename = oldFile.getName();
        }
        
        IpfSourceScaleCounter sc = getSourceScaleCounter(filename);
        if (sc != null) {
            return sc.count(oldFile, newFile);
        }
        return new SourceScaleResult();
    }
    
    /**
     * ソース規模収集可能なファイルの種類かチェックする。
     * 
     * @param file カウント対象ファイル名
     * @return 収集可 true、収集不可 false
     */
    protected static boolean isCountable(String filename) {
        IpfSourceScaleCounter sc = getSourceScaleCounter(filename);
        if(sc.isCountable(filename)) {
            // 収集可能
            return true;
        }
        // 収集不可
        return false;
    }
    
    
    /**
     * ファイルの拡張子に対応するステップカウンターを取得する。
     * 
     * @param file カウント対象ファイル名
     * @return 拡張子に対応するステップカウンター
     */
    protected static IpfSourceScaleCounter getSourceScaleCounter(String filename) {
        
        // 拡張子を取得
        String ext = FilenameUtils.getExtension(filename);
        String regExt = getRegExt(ext);
        
        // 拡張子に対応するカスタムステップカウンタが存在するかチェック
        if (customSourceScaleCounterMap.containsKey(regExt)) {
            // カスタムステップカウンターを使用
            return customSourceScaleCounterMap.get(regExt);
        } else {
            // デフォルトのステップカウンターを使用
            return defaultSourceScaleCounter;
        }
    }
    
    /**
     * 拡張子をカスタムステップカウンタマップ登録時に使用するキー値
     * （小文字、ドット(.)なし）に変換する。
     * 
     * @param ext 拡張子
     * @return マップ登録時のキー値
     */
    protected static String getRegExt(String ext) {
        String regExt = null;
        if (ext != null && ext.length() > 0) {
            regExt = ext.toLowerCase().replaceAll("\\.", "");
        }
        return regExt;
    }
    
    /**
     * 版管理ツールから取得したファイルを作成する一時ディレクトリを作成する。
     * @param prefix 一時ディレクトリ名の接頭辞
     * @param suffix 一時ディレクトリ名の接尾辞
     * @return 作成した一時ディレクトリを返す（ディレクトリ名：[prefix]yyyyMMddHHmmssSSS[suffix]）
     */
    protected static File createTempDirectory(String prefix, String suffix) {
        StringBuilder dirName = new StringBuilder();
        if (prefix != null && prefix.length() > 0) {
            dirName.append(prefix);
        }
        String timestamp = DateFormatUtils.format(new Date(), "yyyyMMddHHmmssSSS");
        dirName.append(timestamp);
        if (suffix != null && suffix.length() > 0) {
            dirName.append(suffix);
        }
        File dir = new File(FileUtils.getTempDirectoryPath() + "/" + dirName.toString());
        if (! dir.exists()) {
            dir.mkdirs();
            log.debug("tmpdir:" + dir.getPath());
        }
        return dir;
    }
    
    
    /**
     * Pentaho 設定ファイル(kettle.properties)からDB接続情報を取得しマップに格納して返す。
     * 
     * @return DB接続情報が格納されたマップ
     * @throws Exception 
     */
    protected static Map<String, String> getPentahoConfigInfo() throws Exception {
        
        Map<String, String> configInfo = new HashMap<String, String>();
        
        // 環境変数(KETTLE_PROP_FILE)から Pentaho 設定ファイル(kettle.properties) のパスを取得する。
        String kettlePropFilePath = System.getenv(SYSTEM_ENV_KETTLE_PROP_FILE);
        log.debug("kettlePropFilePath:" + kettlePropFilePath);
        if (StringUtils.isBlank(kettlePropFilePath)) {
            String msg = String.format(resource.getString("error.system.env.kettle.propfile.path"), SYSTEM_ENV_KETTLE_PROP_FILE);
            throw new Exception(msg);
        }
        
        // Pentaho 設定ファイル(kettle.properties) 読み込みチェック
        File kettlePropFile = new File(kettlePropFilePath);
        if (! kettlePropFile.canRead()) {
            String msg = String.format(resource.getString("error.read.kettle.propfile"), kettlePropFilePath);
            throw new Exception(msg);
        }
        
        // DB接続情報取得
        InputStream is = null;
        try {
            is = FileUtils.openInputStream(kettlePropFile);
            Properties config = new Properties();
            config.load(is);
            
            String dbHost = config.getProperty(KETTLE_PROP_IPF_DB_HOST);
            String dbName = config.getProperty(KETTLE_PROP_IPF_DB_NAME);
            String dbUser = config.getProperty(KETTLE_PROP_IPF_DB_USER);
            String dbPass = config.getProperty(KETTLE_PROP_IPF_DB_PASS);
            String dbPort = config.getProperty(KETTLE_PROP_IPF_DB_PORT);
            String schema = config.getProperty(KETTLE_PROP_IPF_DB_SCHEMA);

            // DBホスト名取得チェック
            if (StringUtils.isBlank(dbHost)) {
                String msg = String.format(resource.getString("error.kettle.propfile.key.dbhost"),
                        kettlePropFilePath, KETTLE_PROP_IPF_DB_HOST);
                throw new Exception(msg);
            }
            // データベース名取得チェック
            if (StringUtils.isBlank(dbName)) {
                String msg = String.format(resource.getString("error.kettle.propfile.key.dbname"),
                        kettlePropFilePath, KETTLE_PROP_IPF_DB_NAME);
                throw new Exception(msg);
            }
            // DBユーザ名取得チェック
            if (StringUtils.isBlank(dbUser)) {
                String msg = String.format(resource.getString("error.kettle.propfile.key.dbuser"),
                        kettlePropFilePath, KETTLE_PROP_IPF_DB_USER);
                throw new Exception(msg);
            }
            
            configInfo.put("dbHost", dbHost);
            configInfo.put("dbPort", dbPort);
            configInfo.put("dbName", dbName);
            configInfo.put("dbUser", dbUser);
            configInfo.put("dbPass", dbPass);
            configInfo.put("schema", schema);

        } finally {
            IOUtils.closeQuietly(is);
        }
        
        return configInfo;
    }
    
    /**
     * Pentaho 設定ファイル(kettle.properties)からRedmine DB接続情報を取得しマップに格納して返す。
     * 
     * @return Redmine DB接続情報が格納されたマップ
     * @throws Exception 
     */
    protected static Map<String, String> getPentahoConfigRedmineDbInfo() throws Exception {
        
        Map<String, String> configInfo = new HashMap<String, String>();
        
        // 環境変数(KETTLE_PROP_FILE)から Pentaho 設定ファイル(kettle.properties) のパスを取得する。
        String kettlePropFilePath = System.getenv(SYSTEM_ENV_KETTLE_PROP_FILE);
        log.debug("kettlePropFilePath:" + kettlePropFilePath);
        if (StringUtils.isBlank(kettlePropFilePath)) {
            String msg = String.format(resource.getString("error.system.env.kettle.propfile.path"), SYSTEM_ENV_KETTLE_PROP_FILE);
            throw new Exception(msg);
        }
        
        // Pentaho 設定ファイル(kettle.properties) 読み込みチェック
        File kettlePropFile = new File(kettlePropFilePath);
        if (! kettlePropFile.canRead()) {
            String msg = String.format(resource.getString("error.read.kettle.propfile"), kettlePropFilePath);
            throw new Exception(msg);
        }
        
        // DB接続情報取得
        InputStream is = null;
        try {
            is = FileUtils.openInputStream(kettlePropFile);
            Properties config = new Properties();
            config.load(is);
            
            String dbHost = config.getProperty(KETTLE_PROP_RM_DB_HOST);
            String dbName = config.getProperty(KETTLE_PROP_RM_DB_NAME);
            String dbUser = config.getProperty(KETTLE_PROP_RM_DB_USER);
            String dbPass = config.getProperty(KETTLE_PROP_RM_DB_PASS);
            String dbPort = config.getProperty(KETTLE_PROP_RM_DB_PORT);
            String schema = config.getProperty(KETTLE_PROP_RM_DB_SCHEMA);

            // DBホスト名取得チェック
            if (StringUtils.isBlank(dbHost)) {
                String msg = String.format(resource.getString("error.kettle.propfile.key.dbhost"),
                        kettlePropFilePath, KETTLE_PROP_RM_DB_HOST);
                throw new Exception(msg);
            }
            // データベース名取得チェック
            if (StringUtils.isBlank(dbName)) {
                String msg = String.format(resource.getString("error.kettle.propfile.key.dbname"),
                        kettlePropFilePath, KETTLE_PROP_RM_DB_NAME);
                throw new Exception(msg);
            }
            // DBユーザ名取得チェック
            if (StringUtils.isBlank(dbUser)) {
                String msg = String.format(resource.getString("error.kettle.propfile.key.dbuser"),
                        kettlePropFilePath, KETTLE_PROP_RM_DB_USER);
                throw new Exception(msg);
            }
            
            configInfo.put("dbHost", dbHost);
            configInfo.put("dbPort", dbPort);
            configInfo.put("dbName", dbName);
            configInfo.put("dbUser", dbUser);
            configInfo.put("dbPass", dbPass);
            configInfo.put("schema", schema);

        } finally {
            IOUtils.closeQuietly(is);
        }
        
        return configInfo;
    }
    
    /**
     * 設定ファイル(kettle.properties)からDB接続情報を取得してDBに接続してコネクション返す。
     * @param configInfo 
     * 
     * @return DBコネクション
     * @throws Exception 
     */
    protected static Connection getDBConnection(Map<String, String> configInfo) throws Exception {
        
        Connection conn = null;
        
        try {
            String dbHost = configInfo.get("dbHost");
            String dbPort = configInfo.get("dbPort");
            String dbName = configInfo.get("dbName");
            String dbUser = configInfo.get("dbUser");
            String dbPass = configInfo.get("dbPass");
            String schema = configInfo.get("schema");
            
            // JDBC URL
            StringBuilder jdbcUrl = new StringBuilder();
            jdbcUrl.append("jdbc:postgresql://");
            jdbcUrl.append(dbHost);
            if (StringUtils.isNotBlank(dbPort)) {
                jdbcUrl.append(":");
                jdbcUrl.append(dbPort);
            }
            jdbcUrl.append("/");
            jdbcUrl.append(dbName);
            
            // DB接続
            conn = DriverManager.getConnection(jdbcUrl.toString(), dbUser, dbPass);
            conn.setAutoCommit(false);
            
            // デフォルトスキーマ設定
            if (StringUtils.isNotBlank(schema)) {
                Statement stmt = conn.createStatement();
                stmt.execute("set search_path to " + schema);
                log.debug("schema:" + schema);
            }
            
        } catch (Exception e) {
            if (conn != null) {
                try {
                    log.debug("rollback");
                    conn.rollback();
                } catch (Exception e2) { }
            }
            throw e;
        }
        return conn;
    }
    
    /**
     * ソース規模データ登録用のプリペアド・ステートメントを作成する。
     * 
     * @param conn DBコネクション
     * @return ソース規模データ登録用プリペアド・ステートメント
     * @throws SQLException 
     */
    protected static PreparedStatement createPstmsInsertSourceScale(Connection conn) throws SQLException {
        PreparedStatement pstmt = null;
        String sql =
                "insert into source_scale ( " +
                "  project_id              ," +
                "  revision                ," +
                "  ticket_id               ," +
                "  file_name               ," +
                "  file_type               ," +
                "  file_path               ," +
                "  change_user             ," +
                "  change_date             ," +
                "  file_size               ," +
                "  source_lines            ," +
                "  source_lines2           ," +
                "  increase_source_lines   ," +
                "  increase_source_lines2  ," +
                "  change_source_lines     ," +
                "  change_source_lines2     " +
                ") values ( " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?, " +
                "  ?  " +
                ")    ";
            pstmt = conn.prepareStatement(sql);
        return pstmt;
    }
    
    /**
     * ソース規模データをDBに登録する。
     * 
     * @param conn DBコネクション
     * @param pstmt ソース規模データ登録用プリペアド・ステートメント
     * @param projectId プロジェクトID
     * @param result ソース規模データ格納オブジェクト
     * @throws Exception 
     */
    protected static void insertSourceScale(
            Connection conn,
            PreparedStatement pstmt,
            String projectId,
            SourceScaleResult result) throws Exception {
        
        // 収集結果ログ出力
        log.debug(result.getResultDetailString());
        
        // 更新日時
        Timestamp changeDate = new Timestamp(
                DateUtils.toCalendar(result.getUpdDate()).getTimeInMillis()); // Date 型 → Timestamp 型変換
        
        // チケットID（コミットログから取得）
        Set<Long> ticketIdSet = getTicketIdFromCommitLog(result.getMessage());
        log.debug("Related Ticket Id:" + ticketIdSet);
        
        int ticketId = 0;
        
        try {
            // チケットID分繰り返し
            for (Long lTicketId : ticketIdSet) {
                ticketId = lTicketId.intValue();
                
                pstmt.clearParameters();
                int i = 1;
                pstmt.setString(i++, projectId);                    // project_id
                pstmt.setString(i++, result.getRevision());         // revision
                pstmt.setInt(i++, ticketId);                        // ticket_id
                pstmt.setString(i++, result.getFileName());         // file_name
                pstmt.setString(i++, result.getFileType());         // file_type
                pstmt.setString(i++, result.getFilePath());         // file_path
                pstmt.setString(i++, result.getAuthor());           // change_user_id
                pstmt.setTimestamp(i++, changeDate);                // change_date
                pstmt.setInt(i++, (int) result.getFileSize());      // file_size
                pstmt.setInt(i++, (int) result.getSourceLine());    // source_lines
                pstmt.setInt(i++, (int) result.getSourceLine2());   // source_lines2
                pstmt.setInt(i++, (int) result.getIncreaseLine());  // increase_source_lines
                pstmt.setInt(i++, (int) result.getIncreaseLine2()); // increase_source_lines2
                pstmt.setInt(i++, (int) result.getChangeLine());    // change_source_lines
                pstmt.setInt(i++, (int) result.getChangeLine2());   // change_source_lines2
                pstmt.executeUpdate();
            }
        } catch (SQLException sqle) {
            String sqlState = sqle.getSQLState();
            if (StringUtils.equals(sqlState, SQL_STATE_KEY_DUPLICATE)) {
                // キー重複 → 無視
                log.debug(sqle.getMessage());
                String msgdup = String.format(resource.getString("info.sourcescale.key.duplicate"),
                        projectId, result.getRevision(), ticketId, result.getFilePath(), result.getFileName());
                log.info(msgdup);
                
                // ロールバック用にカスタマイズした例外をスローする
                throw new IpfSQLNormalException(sqle);
            } else {
                throw sqle;
            }
        }
    }
    
    /**
     * ソース規模データをDBから削除する。
     * 
     * @param conn DBコネクション
     * @param projectId プロジェクトID
     * @param revision リビジョン
     * @throws Exception 
     */
    protected static void deleteSourceScale(
            Connection conn,
            String projectId,
            String revision) throws Exception {
        
        // SQL
        String sql = 
                "DELETE FROM source_scale " +
                " WHERE project_id = ?    " +
                "   AND revision = ?      ";
        
        PreparedStatement pstmt = conn.prepareStatement(sql);
        int i = 1;
        pstmt.setString(i++, projectId);
        pstmt.setString(i++, revision);
        pstmt.executeUpdate();
        
    }
    
    /**
     * コミットログから関連するチケットIDを抽出してセットに格納して返す。
     * 
     * @param commitLog コミットログ
     * @return 関連するチケットIDのセット
     */
    protected static Set<Long> getTicketIdFromCommitLog(String commitLog) {
        
        Set<Long> ticketIdSet = new HashSet<Long>();
        
        // コミットログから関連するチケットIDを抽出（Trac）
        ticketIdSet.addAll(getTicketIdFromCommitLogForTrac(commitLog));
        // コミットログから関連するチケットIDを抽出（Redmine）
        ticketIdSet.addAll(getTicketIdFromCommitLogForRedmine(commitLog));
        
        return ticketIdSet;
    }
    
    /**
     * コミットログから関連するチケットIDを抽出してセットに格納して返す。
     * （Trac 版）
     * 
     * @param commitLog コミットログ
     * @return 関連するチケットIDのセット
     */
    protected static Set<Long> getTicketIdFromCommitLogForTrac(String commitLog) {
        Set<Long> ticketIdSet = new HashSet<Long>();
        
        // コミットログからチケットIDを抽出するための正規表現
        String regexp = 
            "(?:close|closed|closes|fix|fixed|fixes|addresses|references|refs|re|see|[\\s,&]+|[\\s]*and)[\\s]*" + 
            "(?:ticket\\:|issue\\:|bug\\:|#)([0-9]+)";
        
        Pattern p = Pattern.compile(regexp, Pattern.MULTILINE);
        Matcher m = p.matcher(commitLog.toLowerCase());
        while(m.find()){
            if (m.groupCount() > 0) {
                String ticketId = m.group(1);
                log.debug("[Trac] ticketId:" + ticketId);
                ticketIdSet.add(NumberUtils.toLong(ticketId));
            }
        }
        return ticketIdSet;
    }
    
    /**
     * コミットログから関連するチケットIDを抽出してセットに格納して返す。
     * （Redmine 版）
     * 
     * @param commitLog コミットログ
     * @return 関連するチケットIDのセット
     */
    protected static Set<Long> getTicketIdFromCommitLogForRedmine(String commitLog) {
        Set<Long> ticketIdSet = new HashSet<Long>();
        
        // コミットログからチケットIDを抽出するための正規表現
        String regexp = "";
        
        Pattern p = Pattern.compile(regexp, Pattern.MULTILINE);
        Matcher m = p.matcher(commitLog.toLowerCase());
        while(m.find()){
            if (m.groupCount() > 0) {
                String ticketId = m.group(1);
                log.debug("[Redmine] ticketId:" + ticketId);
                ticketIdSet.add(NumberUtils.toLong(ticketId));
            }
        }
        return ticketIdSet;
    }

    /**
     * Trac からリポジトリパスを取得する。
     * 
     * @param projectId プロジェクトID
     * @return リポジトリパス
     * @throws SQLException 
     */
    protected static String getTracRepoPath(String projectId) throws Exception {
        
        String repoPath = null;
        
        // 環境変数(TRAC_PROJECT_ROOT)から Trac プロジェクトルートパスを取得する。
        String tracProjectRootPath = System.getenv(SYSTEM_ENV_TRAC_PROJECT_ROOT);
        log.debug("tracProjectRootPath:" + tracProjectRootPath);
        if (StringUtils.isBlank(tracProjectRootPath)) {
            String msg = String.format(resource.getString("error.system.env.trac.project.root.path"), SYSTEM_ENV_TRAC_PROJECT_ROOT);
            throw new Exception(msg);
        }
        
        String tracProjectPath = FilenameUtils.concat(tracProjectRootPath, projectId);
        log.debug("tracProjectPath:" + tracProjectPath);
        
        Map<String, String> traDbInfoMap = IPFTracUtils.getTracDbInfo(tracProjectPath);
        
        Connection tracDbConn = getDBConnection(traDbInfoMap);
        String schema = traDbInfoMap.get("schema");
        try {
            TracSystemDAO sysDao = new TracSystemDAO(tracDbConn, schema);
            repoPath = sysDao.getRepoPath();
        } finally {
            DbUtils.closeQuietly(tracDbConn);
        }
        
        return repoPath;
    }

    /**
     * Redmine からリポジトリパスを取得する。
     * 
     * @param projectId プロジェクト識別子
     * @return リポジトリパス
     * @throws SQLException 
     */
    protected static String getRedmineRepoPath(String projectId) throws Exception {
        
        String repoPath = null;

        // Redmine DB 接続情報を取得する
        Map<String, String> redmineDbInfoMap = getPentahoConfigRedmineDbInfo();
        
        Connection redmineDbConn = getDBConnection(redmineDbInfoMap);
        String schema = redmineDbInfoMap.get("schema");
        try {
            RedmineRepositoriesDAO repoDao = new RedmineRepositoriesDAO(redmineDbConn, schema);
            repoPath = repoDao.getRepoPath(projectId);
        } finally {
            DbUtils.closeQuietly(redmineDbConn);
        }
        
        return repoPath;
    }

}
