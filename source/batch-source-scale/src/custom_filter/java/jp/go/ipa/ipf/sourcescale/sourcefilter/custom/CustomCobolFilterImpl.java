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

package jp.go.ipa.ipf.sourcescale.sourcefilter.custom;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jp.go.ipa.ipf.sourcescale.sourcefilter.IpfSourceFilter;
import tk.stepcounter.DefaultStepCounter;
import tk.stepcounter.StepCounter;
import tk.stepcounter.diffcount.DiffSource;

/**
 * COBOL用カスタムソースフィルタクラス
 */
public class CustomCobolFilterImpl extends IpfSourceFilter {

    /* (非 Javadoc)
     * @see jp.go.ipa.sourcescale.sourcefilter.IpfSourceFilter#setFileExt(java.util.List)
     */
    @Override
    public void setFileExt(List<String> fileExtList) {
        fileExtList.add("cbl");
    }

    /* (非 Javadoc)
     * @see jp.go.ipa.sourcescale.sourcefilter.IpfSourceFilter#setSourceFilter()
     */
    @Override
    public StepCounter setSourceFilter() {
        CobolStepCounter counter = new CobolStepCounter();
        counter.addLineComment("*");
        counter.setFileType("COBOL");
        return counter;
    }
    
    /**
     * COBOL用ステップカウンタクラス
     */
    class CobolStepCounter extends DefaultStepCounter {
        
        /**
         * 単一行コメントかどうかをチェック
         * COBOL の場合、
         * 
         * @param line ソースコード各行
         * @return コメント行の場合 true、コメント行以外の場合 false を返す。
         */
        private boolean lineCommentCheck(String line){
            
            Pattern    pattern = Pattern.compile("\\d{6}");
            Matcher matcher = pattern.matcher(line);
            line = matcher.replaceAll("");
            
            if(line.startsWith("*")){
                return true;
            }
            return false;
        }
        
        /* (非 Javadoc)
         * @see tk.stepcounter.DefaultStepCounter#cut(java.lang.String)
         */
        @Override
        public DiffSource cut(String source) {
            
            Pattern    pattern = Pattern.compile("\\d{6}");
            Matcher matcher = pattern.matcher(source);
            source = matcher.replaceAll("");
            
            return super.cut(source);
        }
    }

}
