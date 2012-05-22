package jp.go.ipa.ipf.birtviewer.util;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;

public class IPFByteUtils {

	/**
	 * バイト配列を16進文字列に変換する。
	 *
	 * @param byteAry バイト配列
	 * @return  16進文字列
	 */
	public static String toHexString (byte[] byteAry) {
		return toHexString(byteAry, "");
	}
	
	/**
	 * バイト配列を16進文字列に変換する。
	 *
	 * @param byteAry バイト配列
	 * @param delim   区切り文字
	 * @return  16進文字列
	 */
	public static String toHexString (byte[] byteAry, String delim) {
		if(byteAry == null) {
			return null;
		}
		if(delim == null) {
			delim = "";
		}
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < byteAry.length; i++) {
			if (i > 0) {
				sb.append(delim);
			}
			sb.append(toHexString(byteAry[i]));
		}
		return sb.toString();
	}

	/**
	 * バイトを16進文字列に変換する。
	 * @param b バイト
	 * @return 16進文字列
	 */
	public static String toHexString (byte b) {
		String hex = Integer.toHexString(b & 0x00ff).toUpperCase();
		if (hex.length() < 2) {
			hex = "0" + hex;
		}
		return hex;
	}

	/**
	 * バイト文字列をバイト配列に変換する。
	 * @param byteStr バイト文字列
	 * @return バイト配列
	 */
	public static byte[] byteStrToByte(String byteStr) {
		if(byteStr == null) {
			return null;
		}
		byteStr = StringUtils.replace(byteStr, " ", "");
		byte[] bary = null;
		byte b = 0;
		String bStr = null;
		for (int i = 0; i < byteStr.length(); i+=2) {
			bStr = StringUtils.substring(byteStr, i, i+2);
			try {
				b = (byte)Integer.parseInt(bStr, 16);
				bary = ArrayUtils.add(bary, b);
			} catch (Exception e) {
				bary = ArrayUtils.add(bary, (byte)0);
			}
		}
		return bary;
	}
}
