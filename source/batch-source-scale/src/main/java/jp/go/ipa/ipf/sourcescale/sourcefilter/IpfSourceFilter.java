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

package jp.go.ipa.ipf.sourcescale.sourcefilter;

import java.util.ArrayList;
import java.util.List;

import tk.stepcounter.StepCounter;

/**
 * Amateras StepCounter のソースフィルタカスタマイズ用抽象クラス
 * StepCounter が標準で対応していないファイル用のソースフィルタを追加する場合
 * このクラスを実装したクラスを jp.go.ipa.sourcescale.sourcefilter.custom パッケージに
 * 配置することで、集計対象ファイルの種類を追加できる。
 */
public abstract class IpfSourceFilter {
	
    /** ソースフィルタ対象ファイルの拡張子リスト */
	private final List<String> fileExtList = new ArrayList<String>() ;
	
	/** ステップカウンタ */
	private StepCounter stepCounter;
	
	/**
	 * コンストララクタ
	 */
	public IpfSourceFilter() {
		this.setFileExt(this.fileExtList);
		this.stepCounter = this.setSourceFilter();
	}
	
	/**
	 * このソースフィルタクラスで対象となるファイルの拡張子をリストに追加する。
	 * 
	 * @param fileExtList ソースフィルタ対象ファイルの拡張子リスト
	 */
	public abstract void setFileExt(List<String> fileExtList);
	
	/**
	 * このソースフィルタクラスで利用するステップカウンタのインスタンスを生成して返す。
	 * 
	 * @return ステップカウンタのインスタンス
	 */
	public abstract StepCounter setSourceFilter();
	
	/**
	 * ソースフィルタ対象ファイルの拡張子リストを返す。
	 * 
	 * @return ソースフィルタ対象ファイルの拡張子リスト
	 */
	public List<String> getFileExtList() {
		return this.fileExtList;
	}

	/**
	 * ステップカウンタを返す。
	 * 
	 * @return ステップカウンタ
	 */
	public StepCounter getStepCounter() {
	    return stepCounter;
	}
	
}
