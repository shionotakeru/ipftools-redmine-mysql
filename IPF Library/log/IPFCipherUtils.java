package jp.go.ipa.ipf.birtviewer.util;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import org.apache.log4j.Logger;

public class IPFCipherUtils {

	/** 通常のロガー */
    protected static Logger log = Logger.getLogger(IPFCipherUtils.class);
    
    /** 暗号化キー (16文字以内) */
    private static final String CIPHER_KEY = "IPA_IPF";

    /**
     * 文字列を暗号化する。
     *
     * @param text 文字列
     * @return 文字列を暗号化したもの。
     * @throws Exception
     */
    public static String encrypt(String text) {
        String cryptStr = null;
        try {
            log.debug("暗号化(平文)=" + text);
            byte clearText[] = text.getBytes();

            byte[] key = CIPHER_KEY.getBytes(); // 暗号化キー

            SecretKeySpec sksSpec = new SecretKeySpec(key, "Blowfish");
            Cipher cipher = Cipher.getInstance("Blowfish");
            cipher.init(Cipher.ENCRYPT_MODE, sksSpec);
            byte cryptText[] = cipher.doFinal(clearText);

            cryptStr = IPFByteUtils.toHexString(cryptText);
            log.debug("暗号化(暗文)=" + cryptStr);
        } catch(Exception e) {
            log.error("暗号化失敗", e);
        }
        return cryptStr;
    }

    /**
     * 文字列を複号化する。
     *
     * @param text 文字列
     * @return 文字列を複号化したもの。
     * @throws Exception
     */
    public static String decrypt(String text) {
        String decryptStr = null;
        try {
            log.debug("複号化(暗文)=" + text);
            byte decryptText[] = IPFByteUtils.byteStrToByte(text);

            byte[] key = CIPHER_KEY.getBytes(); // 複号化キー

            SecretKeySpec sksSpec = new SecretKeySpec(key, "Blowfish");
            Cipher cipher = Cipher.getInstance("Blowfish");
            cipher.init(Cipher.DECRYPT_MODE, sksSpec);
            byte clearText[] = cipher.doFinal(decryptText);

            decryptStr = new String(clearText);
            log.debug("複号化(平文)=" + decryptStr);
        } catch(Exception e) {
            log.error("複号化失敗", e);
        }
        return decryptStr;
    }


	
}
