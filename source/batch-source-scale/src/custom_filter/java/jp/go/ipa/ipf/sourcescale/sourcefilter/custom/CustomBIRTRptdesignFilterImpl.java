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

import jp.go.ipa.ipf.sourcescale.sourcefilter.IpfSourceFilter;
import tk.stepcounter.AreaComment;
import tk.stepcounter.DefaultStepCounter;
import tk.stepcounter.StepCounter;

/**
 * BIRT Report Design 用カスタムソースフィルタクラス
 * 
 */
public class CustomBIRTRptdesignFilterImpl extends IpfSourceFilter {

    @Override
    public void setFileExt(List<String> fileExtList) {
        fileExtList.add("rptdesign"); // BIRT Redport Design File
    }

    @Override
    public StepCounter setSourceFilter() {
        DefaultStepCounter counter = new DefaultStepCounter();
        counter.addAreaComment(new AreaComment("<!--","-->"));
        counter.setFileType("BIRT RPT");
        return counter;
    }

}
