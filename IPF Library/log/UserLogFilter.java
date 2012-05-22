package jp.go.ipa.ipf.birtviewer.filter;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.Set;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.go.ipa.ipf.birtviewer.util.IPFCipherUtils;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.log4j.MDC;

/**
 * BIRT　Viewer 操作ログ出力 サーブレットフィルタクラス
 * 
 */
public class UserLogFilter implements Filter {

    /** ユーザ操作ログ出力用ロガー */
    protected static Logger userLog = Logger.getLogger("UserLogger");
	/** 通常のロガー */
    protected static Logger log = Logger.getLogger(UserLogFilter.class);
    
    /** 文字コード */
    private final String ENCODING = "UTF-8";

    /** マッピング定義ファイルのキー (URL) */
	private final String PROP_KEY_URL = "[url]";
    /** マッピング定義ファイルのキー (パラメータ) */
	private final String PROP_KEY_PARAM = "[param";
	/** ユーザIDを格納する Cookie の名前 */
	private final String COOKIE_NAME_IPF_USER_ID = "IPF_USER_ID";
	/** ユーザIDを取得する パラメータ名 */
	private final String REQ_PRM_NAME_USER_ID = "UID";
	
	/** MDCキー（IPアドレス） */
	private final String MDC_KEY_ADDRESS = "address";
	/** MDCキー（ユーザ名） */
	private final String MDC_KEY_USER = "user";
	/** MDCキー（機能名） */
	private final String MDC_KEY_FUNCTION = "function";
	/** MDCキー（機能詳細） */
	private final String MDC_KEY_OPERATION = "operation";
	
	/** リクエストメソッド名 */
	private final String REQ_METHOD_NAME_POST = "POST";
	
	/** マッピング定義ファイルを取得するリソース */
	private ResourceBundle resource;

	/** URL情報  */
	private Map<String, String> urlMap = new HashMap<String, String>();
	/** パラメータ情報  */
	private Map<String, String> paramMap = new HashMap<String, String>();

	@Override
	public void init(FilterConfig config) throws ServletException {

		resource = ResourceBundle.getBundle("resources." + UserLogFilter.class.getSimpleName());

		Set<String> propKeySet = resource.keySet();
		for (String propKey : propKeySet) {
			if (propKey.startsWith(PROP_KEY_URL)) {
				// URLマップ
				String value = resource.getString(propKey);
				urlMap.put(propKey, value);

			} else if (propKey.startsWith(PROP_KEY_PARAM)) {
				// パラメータマップ
				String value = resource.getString(propKey);
				paramMap.put(propKey, value);
			}
		}

	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response,
			FilterChain chain) throws IOException, ServletException {

		HttpServletRequest req = ((HttpServletRequest)request);
		HttpServletResponse res = ((HttpServletResponse)response);
		
		// 文字コード設定
		req.setCharacterEncoding(ENCODING);
				
		// 画面名
		String servletPath = StringUtils.defaultString(req.getServletPath());
		String pathInfo = StringUtils.defaultString(req.getPathInfo());
		String url = servletPath + pathInfo;

		log.debug("url=" + url);
		
		// 機能名:機能詳細
		String funcOpeName = null;

		// URLマップに該当するURLがあるか
		if (urlMap.containsKey("[url]" + url)) {
			// ある
			String pageName = urlMap.get("[url]" + url);

			// URLだけで画面名が識別できるか
			if (pageName.startsWith(PROP_KEY_PARAM)) {
				// リクエストメソッド名取得
				String requestMethodName = req.getMethod();
				log.debug(requestMethodName);
				// グラフ表示時のみアクセスログを出力
				if (!REQ_METHOD_NAME_POST.equals(requestMethodName)) {
					endProcess(req, res, chain);
					return;
				}
				
				// パラメータマップを参照する必要がある。
				// パラメータ名
				String prmName = pageName.replaceFirst("\\[param.*\\]", "");
				log.debug("prmName=" + prmName);
				// パラメータ値を取得
				String prmValue = request.getParameter(prmName);

				if (prmValue != null) {
					// パラメータを取得できた場合
					// パラメータマップに該当するパラメータ情報があるか
					if (paramMap.containsKey(pageName + "?" + prmValue)) {
						// ある
						funcOpeName = paramMap.get(pageName + "?" + prmValue);
					} else {
						// ない
						log.debug("param name or value not defined map:" + pageName + "?" + prmValue);
					}
				} else {
					// パラメータを取得できなかった場合
					log.debug("param value dose not get:" + prmValue);
				}

			} else {
				// URLだけで画面名が識別できる
				funcOpeName = pageName;
			}
		} else {
			// ない
			log.debug("url not defined map:" + url);
		}

		// 接続元IPアドレス
		String remoteAddr = req.getRemoteAddr();
		MDC.put(MDC_KEY_ADDRESS, StringUtils.defaultString(remoteAddr));
		
		// ユーザID
		String userId = getUserId(request, response, url);
		MDC.put(MDC_KEY_USER, StringUtils.defaultString(userId));

		// ログ出力
		if (funcOpeName != null) {
			// 機能名
			String[] funcOpe = StringUtils.splitByWholeSeparator(funcOpeName, ":");
			String function = null;
			if (funcOpe.length > 0) {
				function = funcOpe[0];
			}
			MDC.put(MDC_KEY_FUNCTION, StringUtils.defaultString(function));
			// 機能詳細
			String operation = null;
			if (funcOpe.length > 1) {
				operation = funcOpe[1];
			}
			MDC.put(MDC_KEY_OPERATION, StringUtils.defaultString(operation));
			
			// ログ出力
			userLog.info("");
		} else {
			// ログ出力
			userLog.debug(url);
		}
		endProcess(req, res, chain);

	}
	
	/**
	 * 終了処理
	 * 
	 * @param request  リクエスト
	 * @param response レスポンス
	 * @param chain    フィルター
	 * @throws IOException
	 * @throws ServletException
	 */
	private void endProcess(HttpServletRequest req, HttpServletResponse res, FilterChain chain) 
			throws IOException, ServletException {
				
		chain.doFilter(req, res);

		MDC.remove(MDC_KEY_ADDRESS);
		MDC.remove(MDC_KEY_USER);
		MDC.remove(MDC_KEY_FUNCTION);
		MDC.remove(MDC_KEY_OPERATION);
	}

	@Override
	public void destroy() {
		// TODO 自動生成されたメソッド・スタブ
		MDC.clear();
	}
	
	/**
	 * ユーザIDを取得する
	 * 
	 * @param request リクエスト
	 * @param response レスポンス
	 * @return ユーザID
	 */
	private String getUserId(ServletRequest request, ServletResponse response, String url) {
		
		HttpServletRequest req = ((HttpServletRequest)request);
		HttpServletResponse res = ((HttpServletResponse)response);
		
		String userId = null;
		
		// パラメータから取得
		String paramUserId = req.getParameter(REQ_PRM_NAME_USER_ID);
		if (paramUserId != null) {
			log.debug("[Parameter]USER_ID=" + paramUserId);
			userId = paramUserId;
			// Cookie にセット
			String encUserId = IPFCipherUtils.encrypt(userId);
			Cookie userIdCookie = new Cookie(COOKIE_NAME_IPF_USER_ID, encUserId);
			userIdCookie.setPath("/");
			res.addCookie(userIdCookie);
		} else {
        	// Cookie から取得
        	String cookieUserId = null;
        	Cookie[] cookies = req.getCookies();
        	if (cookies != null) {
        		for (int i = 0; i < cookies.length; i++) {
        			Cookie wkCookie = cookies[i];
        			if (StringUtils.equals(wkCookie.getName(), COOKIE_NAME_IPF_USER_ID)) {
        				String encUserId = wkCookie.getValue();
        				cookieUserId = IPFCipherUtils.decrypt(encUserId);
        				log.debug("[Cookie]USER_ID=" + cookieUserId);
        				if (cookieUserId != null) {
        					userId = cookieUserId;
        				}
        				break;
        			}
        		}
        	}
		}
		log.debug("USER_ID=" + userId);
		
		return userId;
	}

}
