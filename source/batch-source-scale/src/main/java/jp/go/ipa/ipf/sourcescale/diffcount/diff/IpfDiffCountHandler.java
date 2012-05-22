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
 * 変更行数をカウントするための{@link IIpfDiffHandler}実装クラス。
 * 
 */
public class IpfDiffCountHandler implements IIpfDiffHandler {

	/** 追加行数 */
	private int	addCount = 0;

	/** 削除行数 */
	private int	delCount = 0;
	
	/** 変更行数 */
	private int modCount = 0;

	/**
	 * {@inheritDoc}
	 */
	public void add(String text) {
		this.addCount++;
	}

	/**
	 * {@inheritDoc}
	 */
	public void delete(String text) {
		this.delCount++;
	}

	/**
	 * {@inheritDoc}
	 */
	public void modify(long count) {
		this.modCount += count;
		this.addCount -= count;
		this.delCount -= count;
	}		

	/**
	 * {@inheritDoc}
	 */
	public void match(String text) {}

	/**
	 * 追加行数を取得します。
	 * 
	 * @return 追加行数
	 */
	public int getAddCount() {
		return this.addCount;
	}

	/**
	 * 削除行数を取得します。
	 * 
	 * @return 削除行数
	 */
	public int getDelCount() {
		return this.delCount;
	}

	/**
	 * 変更行数を取得します。
	 * 
	 * @return 変更行数
	 */
	public int getModCount() {
		return this.modCount;
	}

}
