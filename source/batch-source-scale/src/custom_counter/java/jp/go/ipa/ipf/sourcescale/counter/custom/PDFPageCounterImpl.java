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

package jp.go.ipa.ipf.sourcescale.counter.custom;

import java.io.File;
import java.io.IOException;
import java.util.List;

import jp.go.ipa.ipf.sourcescale.SourceScaleResult;
import jp.go.ipa.ipf.sourcescale.SourceScaleResult.Status;
import jp.go.ipa.ipf.sourcescale.counter.IpfSourceScaleCounter;

import com.itextpdf.text.pdf.PdfReader;

public class PDFPageCounterImpl extends IpfSourceScaleCounter {

	@Override
	public void setFileExt(List<String> fileExtList) {
		fileExtList.add("pdf");
	}
    
    /* (非 Javadoc)
     * @see jp.go.ipa.ipf.sourcescale.counter.IpfSourceScaleCounter#createSourceScaleResult(java.io.File, java.io.File, jp.go.ipa.ipf.sourcescale.SourceScaleResult.Status)
     */
    protected SourceScaleResult countSourceScale(
            File oldFile, File newFile, Status status) {
        
        SourceScaleResult result = new SourceScaleResult();
        
        // ステータス
        result.setStatus(status);
        
        // ファイルサイズ
        long fileSize = 0;
        if (newFile != null) {
            fileSize = newFile.length();
        }
        result.setFileSize(fileSize);
        
        result.setFileType("PDF");
        
        long newLine  = 0;
        long newLine2 = 0;
        long oldLine  = 0;
        long oldLine2 = 0;
        
        if (newFile != null) {
            // 変更後ファイルが存在する
            int pageNum = getNumPages(newFile);
            newLine  = pageNum;
            newLine2 = pageNum;
        }
        
        if (oldFile != null) {
            // 変更前ファイルが存在する
            int pageNum = getNumPages(oldFile);
            oldLine  = pageNum;
            oldLine2 = pageNum;
        }
        
        switch (status) {
            case ADDED :
                // 新規
                result.setSourceLine(newLine);
                result.setSourceLine2(newLine2);
                result.setAddLine(newLine);
                result.setAddLine2(newLine2);
                result.setDelLine(0);
                result.setDelLine2(0);
                result.setModLine(0);
                result.setModLine2(0);
                
                break;
            case MODIFIED :
                // 変更
                
                result.setSourceLine(newLine);
                result.setSourceLine2(newLine2);
                
                long addLine = 0;
                long delLine = 0;
                long modLine = 0;
                
                if (newLine >= oldLine) {
                    addLine = newLine - oldLine;
                } else {
                    delLine = oldLine - newLine;
                }
                
                result.setAddLine(addLine);
                result.setDelLine(delLine);
                result.setModLine(modLine);
                
                result.setAddLine2(addLine);
                result.setDelLine2(delLine);
                result.setModLine2(modLine);
                
                break;
            case REMOVED :
                // 削除
                result.setSourceLine(0);
                result.setSourceLine2(0);
                result.setAddLine(0);
                result.setAddLine2(0);
                result.setDelLine(oldLine);
                result.setDelLine2(oldLine2);
                result.setModLine(0);
                result.setModLine2(0);
                
                break;
        }
        
        // 変化行数（前回リビジョンからの変化行数（削除された行数はマイナス値でカウント））
        result.setIncreaseLine(result.getAddLine() - result.getDelLine());
        result.setIncreaseLine2(result.getAddLine2() - result.getDelLine2());
        
        // 変更行数（前回リビジョンから変更行数（追加・変更・削除行数の総和））
        result.setChangeLine(result.getAddLine() + result.getDelLine() + result.getModLine());
        result.setChangeLine2(result.getAddLine2() + result.getDelLine2() + result.getModLine2());
        
        return result;
    }
    
    /**
     * PDFファイルのページ数を返す。
     * 
     * @param pdfFile PDFファイル
     * @return ページ数
     */
    private int getNumPages(File file) {
        
        int pageNum = 0;
        
        PdfReader reader = null;
        try {
            // PDFファイルの読み込み
            reader = new PdfReader(file.getCanonicalPath());
            // ページ数
            pageNum = reader.getNumberOfPages();
        } catch (IOException ex) {
            ex.printStackTrace();
        } finally {
            if (reader != null) {
                reader.close();
            }
        }
        return pageNum;
    }

}
