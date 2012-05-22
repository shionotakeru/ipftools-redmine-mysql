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

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.apache.commons.io.IOUtils;

/**
 * IPFの設定ファイルを取得するクラス
 */
public class IPFConfig extends Properties {

    private static final long serialVersionUID = 4408919972920870355L;

    private IPFConfig() { }
    
    public static IPFConfig getInstance() throws IOException {
        final IPFConfig prop = new IPFConfig();
        InputStream is = null;
        try {
            is = IPFConfig.class.getClassLoader().getResourceAsStream("ipfConfig.properties");
            prop.load(is);
        } catch (IOException e) {
            e.printStackTrace();
            throw e;
        } finally {
            IOUtils.closeQuietly(is);
        }
        return prop;
    }
}
