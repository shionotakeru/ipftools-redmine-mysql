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
package jp.go.ipa.ipf.birtviewer.util;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.security.Key;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import jp.go.ipa.ipf.birtviewer.exception.IPFException;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.codec.binary.Hex;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;

public class IPFAnalyzeUtils {

    /**
     * 記法をキャメル記法に変換します。
     * 
     * @param s 文字列
     */
    public static String camelize(String s) {
        String sa[] = StringUtils.split(s, "_");
        StringBuilder sb = new StringBuilder();
        if (sa != null) {
            for (int i = 0; i < sa.length; i++) {
                if (i == 0) {
                    sb.append(StringUtils.lowerCase(sa[i]));
                } else {
                    sb.append(StringUtils.capitalize(StringUtils.lowerCase(sa[i])));
                }
            }
        }
        return sb.toString();
    }
    
    /**
     * スタックとレース情報を返す。
     * @param throwable 例外
     * @return スタックトレース情報
     */
    public static String getStackTrace(Throwable throwable) {
        String statckTrace = null;
        StringWriter sw = null;
        try {
            sw =  new StringWriter();
            throwable.printStackTrace(new PrintWriter(sw));
            statckTrace = sw.toString();
        } finally {
            IOUtils.closeQuietly(sw);
        }
        return statckTrace;
    }
    
    /**
     * Base64でエンコードして返す。
     * 
     * @param str 文字列
     * @return Base64でエンコードされた文字列
     */
    public static String encodeBase64(String str) {
        byte[] outData = Base64.encodeBase64(str.getBytes());
        return new String(outData);
    }
    
    /**
     * Base64でデコードして返す。
     * 
     * @param str 文字列
     * @return Base64でデコードドされた文字列
     */
    public static String decodeBase64(String str) {
        byte[] outData = Base64.decodeBase64(str.getBytes());
        return new String(outData);
    }
    
    /**
     * HMAC-SHA1 による メッセージダイジェストを生成して返す。
     * 
     * @param message メッセージ
     * @return HMAC-SHA1 による メッセージダイジェスト
     * @throws IPFException 
     */
    public static String getHmacSha1(String message) throws IPFException {
        String hexDigest = null;
        try {
            String key = IPFConfig.getInstance().getProperty("hmac.private.key");
            if (key == null) {
                throw new IPFException(IPFMessage.getInstance().getFormatString("0311"));
            }
            Key skey = new SecretKeySpec(key.getBytes(), "HmacSHA1");
            Mac mac = Mac.getInstance(skey.getAlgorithm());
            mac.init(skey);
            byte[] digest = mac.doFinal(message.getBytes());
            hexDigest = Hex.encodeHexString(digest);
        } catch (Exception e) {
            throw new IPFException(IPFMessage.getInstance().getFormatString("0312"));
        }
        return hexDigest;
    }

}
