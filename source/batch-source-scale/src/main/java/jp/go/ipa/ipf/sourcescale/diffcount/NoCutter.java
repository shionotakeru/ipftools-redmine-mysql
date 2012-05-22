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

package jp.go.ipa.ipf.sourcescale.diffcount;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang.StringUtils;

import tk.stepcounter.Util;
import tk.stepcounter.diffcount.Cutter;
import tk.stepcounter.diffcount.DiffSource;

/**
 * コメント、空白行の除去を行わないソースフィルタ。
 * 
 */
public class NoCutter implements Cutter {

	private static Pattern CATEGORY_PATTERN = Pattern.compile("\\[\\[(.*?)\\]\\]");
	private static Pattern IGNORE_PATTERN = Pattern.compile("\\[\\[IGNORE\\]\\]");

	private String fileType = "UNDEF";

	public NoCutter(String fileType) {
		this.fileType = fileType;
	}

	@Override
	public DiffSource cut(String source) {
		String line = null;
		String category = "";
		boolean isIgnore = false;
		BufferedReader reader = new BufferedReader(new StringReader(source));

		try {
			while((line = reader.readLine()) != null){
				if(category.length() == 0){
					Matcher matcher = CATEGORY_PATTERN.matcher(line);
					if(matcher.find()){
						category = matcher.group(1);
					}
				}
				if(IGNORE_PATTERN.matcher(line).find()){
					isIgnore = true;
				}
			}
		} catch(IOException ex){
			ex.printStackTrace();
		} finally {
			Util.close(reader);
		}

		// 末尾の空行を削除する
		source = StringUtils.chomp(source);
		
		return new DiffSource(source, isIgnore, category);
	}

	@Override
	public String getFileType() {
		return this.fileType;
	}

}
