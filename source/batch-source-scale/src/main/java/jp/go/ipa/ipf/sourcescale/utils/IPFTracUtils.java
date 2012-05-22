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

package jp.go.ipa.ipf.sourcescale.utils;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jp.go.ipa.ipf.sourcescale.SourceScaleCount;

import org.apache.commons.configuration.HierarchicalConfiguration;
import org.apache.commons.configuration.HierarchicalINIConfiguration;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

/**
 * Trac 関連ユーティリティクラス
 * 
 */
public class IPFTracUtils {

    protected static Logger log = Logger.getLogger(IPFTracUtils.class);

    /**
     * Trac DB の接続情報を tarc.ini から取得する
     * 
     * @param tracProjectPath Trac プロジェクトパス
     * @return Trac DB 接続情報
     * @throws Exception 
     */
    public static Map<String, String> getTracDbInfo(String tracProjectPath) throws Exception {
        
        String tracIniPath = FilenameUtils.concat(tracProjectPath, "conf/trac.ini");
        log.info("tracIniPath=" + tracIniPath);
        
        File tracIniFile = new File(tracIniPath);
        if (! (tracIniFile.isFile() && tracIniFile.canRead())) {
            String errMsg = String.format(SourceScaleCount.resource
                    .getString("trac.ini.cannnot.read"),
                    tracIniPath);
            throw new Exception(errMsg);
        }
        
        HierarchicalConfiguration config = new HierarchicalINIConfiguration(tracIniFile);
        String tracDbUrl = config.getString("trac.database");
        log.info("tracDbUrl=" + tracDbUrl);
        
        // Trac DB URL文字列から DB情報を抽出する
        Map<String, String> tracDbInfo = parseTracDbInfo(tracDbUrl);
        if (tracDbInfo == null || tracDbInfo.isEmpty()) {
            String errMsg = String.format(SourceScaleCount.resource
                    .getString("trac.database.notfound"),
                    tracDbUrl);
            throw new Exception(errMsg);
        }
        
        return tracDbInfo;
    }
    
    /**
     * Trac DB URL文字列からDB情報を取得してマップで返す
     * 
     * @param tracDbUrl Trac データベース URL文字列
     * @return Trac DB情報（マップ）
     */
    protected static Map<String, String> parseTracDbInfo(String tracDbUrl) {
        
        Map<String, String> tracDbInfo = new HashMap<String, String>();
        
        // Trac DB情報解析用正規表現
        String regexp = 
                "(.+)://(.+):(.+)@([^:]+)?(?:\\:([0-9]+))?/([^?]+)(?:\\?schema=(.+))?";
        
        Pattern p = Pattern.compile(regexp, Pattern.MULTILINE);
        Matcher m = p.matcher(tracDbUrl);
        
        String dbType = null;
        String dbUser = null;
        String dbPass = null;
        String dbHost = null;
        String dbPort = null;
        String dbName = null;
        String schema = null;
        
        if(m.find()){
            if (m.groupCount() > 0) {
                if (m.groupCount() >= 1) dbType = m.group(1);
                if (m.groupCount() >= 2) dbUser = m.group(2);
                if (m.groupCount() >= 3) dbPass = m.group(3);
                if (m.groupCount() >= 4) dbHost = m.group(4);
                if (m.groupCount() >= 5) dbPort = m.group(5);
                if (m.groupCount() >= 6) dbName = m.group(6);
                if (m.groupCount() >= 7) schema = m.group(7);
                
                tracDbInfo.put("dbUser", dbUser);
                tracDbInfo.put("dbPass", dbPass);
                tracDbInfo.put("dbHost", StringUtils.defaultString(dbHost, "localhost"));
                tracDbInfo.put("dbPort", StringUtils.defaultString(dbPort, "5432"));
                tracDbInfo.put("dbName", dbName);
                tracDbInfo.put("schema", StringUtils.defaultString(schema, "public"));
            }
        }
        log.info("dbType=" + dbType);
        log.info("dbUser=" + dbUser);
        log.info("dbPass=" + dbPass);
        log.info("dbHost=" + dbHost);
        log.info("dbPort=" + dbPort);
        log.info("dbName=" + dbName);
        log.info("schema=" + schema);
        
        return tracDbInfo;
    }

}
