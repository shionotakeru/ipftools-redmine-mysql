package tk.stepcounter;

import java.util.HashMap;
import java.util.Map;

import jp.go.ipa.ipf.sourcescale.SourceScaleCount;
import jp.go.ipa.ipf.sourcescale.sourcefilter.IpfSourceFilter;

import org.apache.commons.io.FilenameUtils;
import org.apache.log4j.Logger;
import org.seasar.framework.container.S2Container;
import org.seasar.framework.container.factory.S2ContainerFactory;


/**
 * ステップカウンタのインスタンスを生成するファクトリ。
 * このクラスを修正することで簡単に対応する形式を追加することができます。
 *
 * <ul>
 *   <li>2.0.0 - Clojure, Scala</li>
 *   <li>1.16.0 - .htm(HTML), dicon</li>
 *   <li>1.15.0 - VB.NET, C#</li>
 *   <li>1.14.0 - Python, Lua, Haskell</li>
 * </ul>
 */
public class StepCounterFactory {
    
    /** ロガー */
    protected static Logger log = Logger.getLogger(SourceScaleCount.LOGGER_NAME);

	/**
	 * カスタムステップカウンタ登録用マップ 
	 * （IPF用に追加）
	 **/
	private static Map<String, StepCounter> customStepCounterMap = new HashMap<String, StepCounter>();
	
	/**
	 * 設定ファイルのPath
     * （IPF用に追加）
	 */
    private static final String PATH = "StepCounterFactory.dicon";
    
    /**
     * DIコンテナ(Seasar2)を初期化
     * （IPF用に追加）
     */
    static {
        try {
    		S2Container container = S2ContainerFactory.create(PATH);
    		container.init();
    		
    		// カスタムステップカウンターを取得してマップに登録
    		// カスタムステップカウンタークラスはパッケージ jp.go.ipa.sourcescale.sourcefilter.custom 配下に、
    		// IpfSourceFilter クラスを継承して作成する。
    		for (int i = 0; i < container.getComponentDefSize(); i++) {
    			
    			Object component = container.getComponentDef(i).getComponent();
                if (component instanceof IpfSourceFilter) {
                	// カスタムソースフィルタクラスの場合
                	IpfSourceFilter sourceFilter = (IpfSourceFilter) component;
                	
            		StepCounter stepCounter = sourceFilter.getStepCounter();
            		if (stepCounter != null) {
            			
                    	for (String ext : sourceFilter.getFileExtList()) {
                    		String regExt = getRegExt(ext);
                    		if (regExt != null) {
                            	// 対応する拡張子をキーにしてマップに登録
                    			customStepCounterMap.put(regExt, stepCounter);
                                log.debug(String.format("Custom Filter Loaded : [%s] : %s",
                                        regExt, stepCounter.getClass().getName()));
                    		}
                    	}
            		}
                }
    		}
        } catch (Exception e) {
            String msg = SourceScaleCount.resource.getString("error.load.custom.filter");
            log.error(msg, e);
        }
    }
    
	/**
	 * カスタムステップカウンタマップ登録時に使用するキー値（小文字）に変換
	 * 先頭にドット(.)が付いていない場合は付加する。
     * （IPF用に追加）
	 * 
	 * @param ext 拡張子
	 * @return マップ登録時のキー値
	 */
	private static String getRegExt(String ext) {
		String regExt = null;
		if (ext != null && ext.length() > 0) {
			regExt = ext.toLowerCase();
			if (! regExt.startsWith(".")) {
				regExt = "." + regExt;
			}
		}
		return regExt;
	}
	
	/**
	 * Java用のカウンタを作成します。
	 */
	private static DefaultStepCounter createJavaCounter(String name){
		DefaultStepCounter counter = new DefaultStepCounter();
		counter.addLineComment("//");
		counter.addAreaComment(new AreaComment("/*","*/"));
		counter.setFileType(name);
//		counter.addSkipPattern("^package .+;$");
//		counter.addSkipPattern("^import .+;$");
		return counter;
	}

	/**
	 * VB用のカウンタを作成します。
	 */
	private static DefaultStepCounter createVBCounter(String name){
		DefaultStepCounter counter = new DefaultStepCounter();
		counter.addLineComment("'");
		counter.addLineComment("REM");
		counter.setFileType(name);
		return counter;
	}

	/**
	 * シェルスクリプト用のカウンタを作成します。
	 */
	private static DefaultStepCounter createShellCounter(String name){
		DefaultStepCounter counter = new DefaultStepCounter();
		counter.addLineComment("#");
		counter.setFileType(name);
		return counter;
	}

	/**
	 * XML用のカウンタを作成します。
	 */
	private static DefaultStepCounter createXMLCounter(String name){
		DefaultStepCounter counter = new DefaultStepCounter();
		counter.addAreaComment(new AreaComment("<!--","-->"));
		counter.setFileType(name);
		return counter;
	}

	/**
	 * Lisp用のカウンタを作成します。
	 */
	private static DefaultStepCounter createListCounter(String name){
		DefaultStepCounter counter = new DefaultStepCounter();
		counter.addLineComment(";");
		counter.setFileType(name);
		return counter;
	}

	/**
	 * ステップカウンタのインスタンスを取得します。
	 * 未対応の形式の場合、nullを返します。
	 *
	 * @param fileName ファイル名
	 * @return ファイル名に対応したステップカウンタのインスタンス。未対応の場合null。
	 */
	public static StepCounter getCounter(String fileName){
		// 小文字に変換
		fileName = fileName.toLowerCase();
		
        //----------------------------------------------------------
		// カスタムステップカウンタを取得
		// (IPF用に追加)
        //----------------------------------------------------------
		String ext = FilenameUtils.getExtension(fileName);
		StepCounter sc = customStepCounterMap.get(getRegExt(ext));
		if (sc != null) {
			// カスタムステップカウンタを取得できた場合
			return sc;
		}
		//----------------------------------------------------------

		if(fileName.endsWith(".java")){
			// Java用カウンタを作成
			return createJavaCounter("Java");

		} else if(fileName.endsWith(".scala")){
			// Scala用カウンタを作成
			return createJavaCounter("Scala");

		} else if(fileName.endsWith(".cpp") || fileName.endsWith(".c")){
			// C/C++用カウンタを作成
			return createJavaCounter("C/C++");

		} else if(fileName.endsWith(".h")){
			//ヘッダファイル用カウンタを作成
			return createJavaCounter("h");

		} else if(fileName.endsWith(".cs")){
			// C#用カウンタを作成
			return createJavaCounter("C#");

		} else if(fileName.endsWith(".jsp")){
			// JSP用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addLineComment("//");
			counter.addAreaComment(new AreaComment("/*","*/"));
			counter.addAreaComment(new AreaComment("<%--","--%>"));
			counter.addAreaComment(new AreaComment("<!--","-->"));
			counter.setFileType("JSP");
			return counter;

		} else if(fileName.endsWith(".php") || fileName.endsWith(".php3")){
			// PHP用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addLineComment("//");
			counter.addAreaComment(new AreaComment("/*","*/"));
			counter.addAreaComment(new AreaComment("<!--","-->"));
			counter.setFileType("PHP");
			return counter;

		} else if(fileName.endsWith(".asp") || fileName.endsWith(".asa")){
			// ASP用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addLineComment("'");
			counter.addAreaComment(new AreaComment("<!--","-->"));
			counter.setFileType("ASP");
			return counter;

		} else if(fileName.endsWith(".html") || fileName.endsWith(".htm")){
			// HTML用カウンタを作成
			return createXMLCounter("HTML");

		} else if(fileName.endsWith(".xhtml")){
			// XHTML用カウンタを作成
			return createXMLCounter("XHTML");

		} else if(fileName.endsWith(".js")){
			// JavaScript用カウンタを作成
			return createJavaCounter("js");

		} else if(fileName.endsWith(".vbs")){
			// VBScript用カウンタを作成
			return createVBCounter("vbs");

		} else if(fileName.endsWith(".bas") || fileName.endsWith(".frm") || fileName.endsWith(".cls")){
			// VB用カウンタを作成
			return createVBCounter("VB");

		} else if(fileName.endsWith(".vb")){
			// VB.NET用カウンタを作成
			return createVBCounter("VB.NET");

		} else if(fileName.endsWith(".pl") || fileName.endsWith(".pm")){
			// Perl用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addLineComment("#");
			counter.addAreaComment(new AreaComment("=pod","=cut"));
			counter.setFileType("Perl");
			return counter;

		} else if(fileName.endsWith(".py")){
			// Python用カウンタを作成
//			DefaultStepCounter counter = new DefaultStepCounter();
//			counter.addLineComment("#");
//			counter.setFileType("Python");
			return new PythonCounter();

		} else if(fileName.endsWith(".rb")){
			// Ruby用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addLineComment("#");
			counter.addAreaComment(new AreaComment("=begin","=end"));
			counter.setFileType("Ruby");
			return counter;

		} else if(fileName.endsWith(".tcl")){
			// Tcl用カウンタを作成
			return createShellCounter("Tcl");

		} else if(fileName.endsWith(".sql")){
			// SQL用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addLineComment("#");
			counter.addLineComment("--");
			counter.addLineComment("REM");
			counter.addAreaComment(new AreaComment("/*","*/"));
			counter.setFileType("SQL");
			return counter;

		} else if(fileName.endsWith(".cfm")){
			// ColdFusion用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addAreaComment(new AreaComment("<!--","-->"));
			counter.addAreaComment(new AreaComment("<!---","--->"));
			counter.setFileType("CFM");
			return counter;

		} else if(fileName.endsWith(".properties")) {
			// プロパティファイル用カウンタを作成
			return createShellCounter("Properties");

		} else if(fileName.endsWith(".xml") || fileName.endsWith(".dicon")) {
			// XML用カウンタを作成
			return createXMLCounter("XML");

		} else if(fileName.endsWith(".xsl")) {
			// XSLT用カウンタを作成
			return createXMLCounter("XSLT");

		} else if(fileName.endsWith(".xi")) {
			// Xi用カウンタを作成
			return createXMLCounter("Xi");

		} else if(fileName.endsWith(".dtd")) {
			// DTD用カウンタを作成
			return createXMLCounter("DTD");

		} else if(fileName.endsWith(".tld")) {
			// TLD用カウンタを作成
			return createXMLCounter("TLD");

		} else if(fileName.endsWith(".xsd")) {
			// XMLSchema用カウンタを作成
			return createXMLCounter("XMLSchema");

		} else if(fileName.endsWith(".bat")){
			// BATファイル用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addLineComment("REM");
			counter.setFileType("BAT");
			return counter;

		} else if(fileName.endsWith(".css")){
			// CSS用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addAreaComment(new AreaComment("/*","*/"));
			counter.setFileType("CSS");
			return counter;

		} else if(fileName.endsWith(".l") || fileName.endsWith(".el") || fileName.endsWith(".cl")){
			// Lisp用カウンタを作成
			return createListCounter("Lisp");

		} else if(fileName.endsWith(".clj")){
			// Clojure用カウンタを作成
			return createListCounter("Clojure");

		} else if(fileName.endsWith(".scm")){
			// Scheme用カウンタを作成
			return createListCounter("Scheme");

		} else if(fileName.endsWith(".st")){
			// Smalltalk用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addAreaComment(new AreaComment("\"","\""));
			counter.setFileType("Smalltalk");
			return counter;

		} else if(fileName.endsWith(".vm") || fileName.endsWith(".vsl")){
			// Velocity用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addLineComment("##");
			counter.setFileType("Velocity");
			return counter;

		} else if(fileName.endsWith(".ini")){
			// INI用カウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addLineComment(";");
			counter.setFileType("INI");
			return counter;

		} else if(fileName.endsWith(".lua")){
			// Luaカウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addLineComment("--");
			counter.addAreaComment(new AreaComment("--[[","]]"));
			counter.addAreaComment(new AreaComment("--[===[","]===]"));
			counter.setFileType("Lua");
			return counter;

		} else if(fileName.endsWith(".hs")){
			// Haskellカウンタを作成
			DefaultStepCounter counter = new DefaultStepCounter();
			counter.addLineComment("--");
			counter.addAreaComment(new AreaComment("{-","-}"));
			counter.setFileType("Haskell");
			return counter;

		} else {
			return null;
		}
	}
}