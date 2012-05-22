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
import java.io.FileInputStream;
import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.util.ArrayList;
import java.util.List;

import jp.go.ipa.ipf.sourcescale.SourceScaleCount;
import jp.go.ipa.ipf.sourcescale.SourceScaleResult;
import jp.go.ipa.ipf.sourcescale.SourceScaleResult.Status;
import jp.go.ipa.ipf.sourcescale.diffcount.NoCutter;
import jp.go.ipa.ipf.sourcescale.diffcount.diff.IpfDiffCountHandler;
import jp.go.ipa.ipf.sourcescale.diffcount.diff.IpfDiffEngine;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.mozilla.universalchardet.UniversalDetector;

import tk.stepcounter.StepCounter;
import tk.stepcounter.StepCounterFactory;
import tk.stepcounter.diffcount.Cutter;
import tk.stepcounter.diffcount.CutterFactory;
import tk.stepcounter.diffcount.DiffCounterUtil;
import tk.stepcounter.diffcount.DiffSource;

/**
 * ソースステップ数カウント用デフォルトクラス
 * 
 */
/**
 * @author sugawara.norikazu
 *
 */
public class IpfDefaultSourceScaleCounterImpl extends IpfSourceScaleCounter {
    
    /** ロガー */
    protected static Logger log = Logger.getLogger(SourceScaleCount.LOGGER_NAME);
    
    /** 文字コード判定用クラス */
    protected static UniversalDetector detector = new UniversalDetector(null);
    
    /**
     * ファイルの文字コードを判別して返す。
     * 
     * @param file ファイル
     * @return 文字コード
     */
    private static String getEncoding(File file) {
        
        String encoding = System.getProperty("file.encoding");
        
        FileInputStream fis = null;
        try {
            byte[] buf = new byte[4096];
            fis = FileUtils.openInputStream(file);
            int nread;
            while ((nread = fis.read(buf)) > 0 && !detector.isDone()) {
                detector.handleData(buf, 0, nread);
            }
            detector.dataEnd();
            
            if (detector.getDetectedCharset() != null) {
                encoding = detector.getDetectedCharset();
            }
            
        } catch (Exception e) {
            //
        } finally {
            IOUtils.closeQuietly(fis);
            detector.reset();
        }
        log.debug(String.format("Encodeing : %s (%s).", file, encoding));
        return encoding;
    }
    
    
    /* (非 Javadoc)
     * @see jp.go.ipa.ipf.sourcescale.counter.IpfSourceScaleCounter#setFileExt(java.util.List)
     */
    @Override
	public void setFileExt(List<String> fileExtList) {
		// デフォルトクラスのため全ての拡張子に対応
	}

    /* (非 Javadoc)
     * @see jp.go.ipa.ipf.sourcescale.counter.IpfSourceScaleCounter#countSourceScale(java.io.File, java.io.File, jp.go.ipa.ipf.sourcescale.SourceScaleResult.Status)
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
		
		// ファイルタイプに応じたカッター（コメント、空行を除去）
		Cutter cutter2 = CutterFactory.getCutter(newFile != null ? newFile : oldFile);
		if (cutter2 == null) {
			// カッターを取得できなかった場合 → カウントしない
			result.setFileType("UNDEF");
			return result;
		}
		// ファイル種別
		String fileType = cutter2.getFileType();
		result.setFileType(fileType);
		
		// 何もしないカッター（コメント、空行を除去しない）
		Cutter cutter = new NoCutter(fileType);
		
		long newLine  = 0;
		long newLine2 = 0;
		long oldLine  = 0;
		long oldLine2 = 0;
		
		DiffSource newSource  = null;
		DiffSource newSource2 = null;
		DiffSource oldSource  = null;
		DiffSource oldSource2 = null;
		
		String charset = null;
		
		if (newFile != null) {
			// 変更後ファイルが存在する
		    charset = getEncoding(newFile);
		    newSource  = cutter.cut(DiffCounterUtil.getSource(newFile, charset));	
			newSource2 = cutter2.cut(DiffCounterUtil.getSource(newFile, charset));
			
			newLine  = DiffCounterUtil.split(newSource.getSource()).length;
			newLine2 = DiffCounterUtil.split(newSource2.getSource()).length;
		}
		
		if (oldFile != null) {
			// 変更前ファイルが存在する
		    if (charset == null) {
	            charset = getEncoding(oldFile);
		    }
			oldSource  = cutter.cut(DiffCounterUtil.getSource(oldFile, charset));	
			oldSource2 = cutter2.cut(DiffCounterUtil.getSource(oldFile, charset));
			
			oldLine  = DiffCounterUtil.split(oldSource.getSource()).length;
			oldLine2 = DiffCounterUtil.split(oldSource2.getSource()).length;
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
				
				IpfDiffCountHandler handler = new IpfDiffCountHandler();
				IpfDiffEngine engine = new IpfDiffEngine(handler, oldSource.getSource(), newSource.getSource());
				engine.doDiff();
				result.setAddLine(handler.getAddCount());
				result.setDelLine(handler.getDelCount());
				result.setModLine(handler.getModCount());
				
				IpfDiffCountHandler handler2 = new IpfDiffCountHandler();
				IpfDiffEngine engine2 = new IpfDiffEngine(handler2, oldSource2.getSource(), newSource2.getSource());
				engine2.doDiff();
				result.setAddLine2(handler2.getAddCount());
				result.setDelLine2(handler2.getDelCount());
				result.setModLine2(handler2.getModCount());
				
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
	

	/* (非 Javadoc)
	 * @see jp.go.ipa.ipf.sourcescale.counter.IpfSourceScaleCounter#isCountable(java.lang.String)
	 */
	public boolean isCountable(String filename) {
	    
        // ファイルタイプに応じたカッターが存在するかチェックする
        StepCounter counter = StepCounterFactory.getCounter(filename);
        if (counter != null) {
            return true;
        }
	    return false;
	}

}
