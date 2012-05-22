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

package jp.go.ipa.ipf.sourcescale.diffcount.diff;

/**
 * Diffクラスから通知を受け取るためのハンドラのインターフェース。
 * 
 */
public interface IIpfDiffHandler {

	/** 行が一致した場合に呼び出されます。 */
	public void match(String text);

	/** 行が削除されていた場合に呼び出されます。 */
	public void delete(String text);

	/** 行が追加されていた場合に呼び出されます。 */
	public void add(String text);

	/** 変更行数を追加します。 */
	public void modify(long count);
}
