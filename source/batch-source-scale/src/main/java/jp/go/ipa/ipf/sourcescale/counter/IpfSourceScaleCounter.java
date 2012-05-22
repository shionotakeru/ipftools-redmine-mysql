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

package jp.go.ipa.ipf.sourcescale.counter;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.FilenameUtils;

import jp.go.ipa.ipf.sourcescale.SourceScaleResult;
import jp.go.ipa.ipf.sourcescale.SourceScaleResult.Status;

/**
 * ソースステップ数カウント用クラスの抽象クラス。
 * 
 */
public abstract class IpfSourceScaleCounter {
	
    /** ソースステップ数カウント対象ファイルの拡張子を格納 */
	protected final List<String> fileExtList = new ArrayList<String>();
	
	public IpfSourceScaleCounter() {
		this.setFileExt(this.fileExtList);
	}

	/**
	 * 変更前ファイル、変更後ファイルから変更種別を判別し
	 * ソース規模収集処理を呼ぶ。
	 * 
	 * @param oldFile 変更前ファイル
	 * @param newFile 変更後ファイル
	 * @return ソース規模収集結果
	 */
    public SourceScaleResult count(File oldFile, File newFile) {
        
        SourceScaleResult result = new SourceScaleResult();
        
        if ((oldFile != null && oldFile.exists()) &&
            (newFile != null && newFile.exists())) {
            // 変更前、変更後両方のファイルがある場合
            // 更新
            result = countSourceScale(oldFile, newFile, Status.MODIFIED);
            
        } else if ((oldFile != null && oldFile.isFile()) &&
                (newFile == null || !newFile.exists())) {
            // 変更前ファイルのみ存在する場合
            // 削除
            result = countSourceScale(oldFile, null, Status.REMOVED);
            
        } else if ((newFile != null && newFile.isFile()) &&
                (oldFile == null || !oldFile.exists())) {
            // 変更後ファイルのみ存在する場合
            // 新規       
            result = countSourceScale(null, newFile, Status.ADDED);
        }
        
        return result;
    }
    
	public abstract void setFileExt(List<String> fileExtList);
	
	/**
	 * 変更前ファイル、変更後ファイルからソース規模を収集して返す。
	 * 
	 * @param oldFile 変更前ファイル
	 * @param newFile 変更後ファイル
	 * @param status 変更種別
	 * @return ソース規模収集結果
	 */
	protected abstract SourceScaleResult countSourceScale(
	        File oldFile, File newFile, Status status);
	
	public List<String> getFileExtList() {
		return this.fileExtList;
	}
	
    /**
     * 指定したファイルのソース規模が収集可能かどうかを返す。
     * 
     * @param filename ファイル名
     * @return true : 収集可能、false : 収集不可
     */
	public boolean isCountable(String filename) {
        
        if (filename != null) {
            String ext = FilenameUtils.getExtension(filename);
            if (fileExtList.contains(ext)) {
                return true;
            }
        }
        return false;
    }

}
