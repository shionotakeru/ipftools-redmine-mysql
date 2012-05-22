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

package jp.go.ipa.ipf.sourcescale.exception;

import java.sql.SQLException;

/**
 * SQL実行でエラーが発生した場合に、
 * ロールバックは行うが正常終了として処理するための例外クラス。
 */
public class IpfSQLNormalException extends SQLException {
    
    /**
     * コンストラクタ
     * @param e 例外
     */
    public IpfSQLNormalException(Exception e) {
        super(e);
    }
}

