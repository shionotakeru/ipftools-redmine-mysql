// フレームオプション
var options = 'scrollbars=yes, resizable=yes, menubar=yes, toolbar=yes, location=yes, directories=yes, status=yes';
var changeFrame = 'changeFrame';
var baseURL = './popup.html';
var blankURL = './blank.html';
// RS系フレーム
var mainFrame = 'mainFrame';
var menuFrame = 'menuFrame';
// RM系
var naviFrame = 'frame1';
var dashBoardFrame = 'frame2';
// 待機時間（ミリ秒）
var sleepTime = 10000;
// ユーザID
var user_id = 'USER_ID=';
// ナビゲーションhtmlの表示制御
var navigation = 'navigation_';
// 拡張子
var extension = '.html';

var blank = '';
var semicolon = ';';
var and = '&';
var question = '?';

/**
 * cookieから情報を取得する。
 * なければ空文字を返す。
 * 
 * @param   key 検索させるキー
 * @returns 該当結果
 */
function loadCookie(key) {    
    var data = blank;
    var cookieData = document.cookie + semicolon;
    var startPoint = cookieData.indexOf(key);
    if (startPoint != -1) {
        var endPoint = cookieData.indexOf(semicolon, startPoint);
        data = and;
        data += cookieData.substring(startPoint, endPoint);
    }
    return data;
}

/**
 * 新規ウインドを立ち上げる
 * 
 * @param url ポップアップするURL
 */
function popup(url) {
    parent.window.open(url, blank, options);
}

/**
 * サブウインド（R_SXX系）のウインド操作
 * グラフ単位のサブウインドを開く
 * 
 * @param url        グラフ用URL
 * @param title      タイトル
 * @param graphId    グラフID
 * @param projectId  プロジェクトID
 */
function subWindowOpen(url, title, graphId, projectId) {
    // クッキーからユーザ情報を取得
    var userId = loadCookie(user_id);
    url += userId;
    // ウインド用のサブウインド名を生成
    var windowName = blank;
    // 複数ウインド対応（空文字で判定）
    if (graphId != null && graphId && graphId != blank) {
        windowName = projectId + graphId;
    }
    if (parent.window.name == windowName && windowName != blank) {
        // サブウインドのフレームURLを直接書き換える
        parent.window.document.getElementById(changeFrame).src = url;
        parent.window.document.title = title;
    } else {
        var menuUrl = navigation + projectId + extension;
        windowLoad(baseURL, windowName, menuFrame, changeFrame, menuUrl, url, title);
    }
}

/**
 * ポップアップウインドを開く
 * 
 * @param base       書き換え元URL
 * @param windowName ウインドウ名
 * @param fn1        フレーム名1(ナビゲーション)
 * @param fn2        フレーム名2(グラフ)
 * @param fn1URL     フレーム1URL(ナビゲーション)
 * @param fn2URL     フレーム2URL(グラフ)
 * @param title      ウインドタイトル
 */
function windowLoad(base, windowName, fn1, fn2, fn1URL, fn2URL, title) {
    var win = parent.window.open(base, windowName, options);
    var dummy = window.open(blankURL, changeFrame, options);
    dummy.close();
    var dateTime = new Date().getTime();
    while (true) {
        if ((win && win.document && win.document.body && win.document.getElementById) 
                || isAfterTime(dateTime, sleepTime)) {
            break;
        }
    }
    win.document.getElementById(fn1).src = fn1URL;
    win.document.getElementById(fn2).src = fn2URL;
    win.document.title = title;
    win.focus();
}

/**
 * メインウインド（R_MXX系）のウインド操作
 * ナビゲーションエリアは選択したウインドのプロジェクトへ書き換える
 * 
 * @param mainURL   ダッシュボード系メインURL
 * @param url       メインウインドに設定するURL
 * @param title     タイトル
 * @param projectId プロジェクトID
 */
function mainWindowOpen(mainURL, url, title, projectId) {
    // クッキーからユーザ情報を取得
    var userId = loadCookie(user_id);
    if (url.indexOf(question) < 0 && userId != blank) {
        // URLパラメータがない場合
        url += question;
        userId = userId.replace(and, blank);
    }
    url += userId;
    // ナビゲーションメニュー用URL
    var menuUrl = navigation + projectId + extension;
    // ウインド判定
    if (parent.window.name == mainFrame) {
        // メインウインドのフレームURLを直接書き換える
        parent.window.document.getElementById(naviFrame).src = menuUrl;
        parent.window.document.getElementById(dashBoardFrame).src = url;
        parent.window.document.title = title;
    } else {
        windowLoad(mainURL, mainFrame, naviFrame, dashBoardFrame, menuUrl, url, title);
    }
}

/**
 * 指定URLに切り替える
 * 
 * @param url ダッシュボードへの遷移先URL
 */
function changeLocation(url) {
    // クッキーからユーザ情報を取得
    var userId = loadCookie(user_id);
    if (url.indexOf(question) < 0 && userId != blank) {
        // URLパラメータがない場合
        url += question;
        userId = userId.replace(and, blank);
    }
    url += userId;
    top.location.href = url;
}

/**
 * 現在日時が指定日時+指定時間を過ぎているか判定
 * 
 * @param dateTime 停止対象時間
 * @param ms       停止時間(ミリ秒)
 * @returns true or false 
 */
function isAfterTime(dateTime, ms) {
    var d2 = new Date().getTime();
    if (d2 < (dateTime + ms)) {
        return false;
    }
    return true;
}