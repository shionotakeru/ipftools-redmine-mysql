// �t���[���I�v�V����
var options = 'scrollbars=yes, resizable=yes, menubar=yes, toolbar=yes, location=yes, directories=yes, status=yes';
var changeFrame = 'changeFrame';
var baseURL = './popup.html';
var blankURL = './blank.html';
// RS�n�t���[��
var mainFrame = 'mainFrame';
var menuFrame = 'menuFrame';
// RM�n
var naviFrame = 'frame1';
var dashBoardFrame = 'frame2';
// �ҋ@���ԁi�~���b�j
var sleepTime = 10000;
// ���[�UID
var user_id = 'USER_ID=';
// �i�r�Q�[�V����html�̕\������
var navigation = 'navigation_';
// �g���q
var extension = '.html';

var blank = '';
var semicolon = ';';
var and = '&';
var question = '?';

/**
 * cookie��������擾����B
 * �Ȃ���΋󕶎���Ԃ��B
 * 
 * @param   key ����������L�[
 * @returns �Y������
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
 * �V�K�E�C���h�𗧂��グ��
 * 
 * @param url �|�b�v�A�b�v����URL
 */
function popup(url) {
    parent.window.open(url, blank, options);
}

/**
 * �T�u�E�C���h�iR_SXX�n�j�̃E�C���h����
 * �O���t�P�ʂ̃T�u�E�C���h���J��
 * 
 * @param url        �O���t�pURL
 * @param title      �^�C�g��
 * @param graphId    �O���tID
 * @param projectId  �v���W�F�N�gID
 */
function subWindowOpen(url, title, graphId, projectId) {
    // �N�b�L�[���烆�[�U�����擾
    var userId = loadCookie(user_id);
    url += userId;
    // �E�C���h�p�̃T�u�E�C���h���𐶐�
    var windowName = blank;
    // �����E�C���h�Ή��i�󕶎��Ŕ���j
    if (graphId != null && graphId && graphId != blank) {
        windowName = projectId + graphId;
    }
    if (parent.window.name == windowName && windowName != blank) {
        // �T�u�E�C���h�̃t���[��URL�𒼐ڏ���������
        parent.window.document.getElementById(changeFrame).src = url;
        parent.window.document.title = title;
    } else {
        var menuUrl = navigation + projectId + extension;
        windowLoad(baseURL, windowName, menuFrame, changeFrame, menuUrl, url, title);
    }
}

/**
 * �|�b�v�A�b�v�E�C���h���J��
 * 
 * @param base       ����������URL
 * @param windowName �E�C���h�E��
 * @param fn1        �t���[����1(�i�r�Q�[�V����)
 * @param fn2        �t���[����2(�O���t)
 * @param fn1URL     �t���[��1URL(�i�r�Q�[�V����)
 * @param fn2URL     �t���[��2URL(�O���t)
 * @param title      �E�C���h�^�C�g��
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
 * ���C���E�C���h�iR_MXX�n�j�̃E�C���h����
 * �i�r�Q�[�V�����G���A�͑I�������E�C���h�̃v���W�F�N�g�֏���������
 * 
 * @param mainURL   �_�b�V���{�[�h�n���C��URL
 * @param url       ���C���E�C���h�ɐݒ肷��URL
 * @param title     �^�C�g��
 * @param projectId �v���W�F�N�gID
 */
function mainWindowOpen(mainURL, url, title, projectId) {
    // �N�b�L�[���烆�[�U�����擾
    var userId = loadCookie(user_id);
    if (url.indexOf(question) < 0 && userId != blank) {
        // URL�p�����[�^���Ȃ��ꍇ
        url += question;
        userId = userId.replace(and, blank);
    }
    url += userId;
    // �i�r�Q�[�V�������j���[�pURL
    var menuUrl = navigation + projectId + extension;
    // �E�C���h����
    if (parent.window.name == mainFrame) {
        // ���C���E�C���h�̃t���[��URL�𒼐ڏ���������
        parent.window.document.getElementById(naviFrame).src = menuUrl;
        parent.window.document.getElementById(dashBoardFrame).src = url;
        parent.window.document.title = title;
    } else {
        windowLoad(mainURL, mainFrame, naviFrame, dashBoardFrame, menuUrl, url, title);
    }
}

/**
 * �w��URL�ɐ؂�ւ���
 * 
 * @param url �_�b�V���{�[�h�ւ̑J�ڐ�URL
 */
function changeLocation(url) {
    // �N�b�L�[���烆�[�U�����擾
    var userId = loadCookie(user_id);
    if (url.indexOf(question) < 0 && userId != blank) {
        // URL�p�����[�^���Ȃ��ꍇ
        url += question;
        userId = userId.replace(and, blank);
    }
    url += userId;
    top.location.href = url;
}

/**
 * ���ݓ������w�����+�w�莞�Ԃ��߂��Ă��邩����
 * 
 * @param dateTime ��~�Ώێ���
 * @param ms       ��~����(�~���b)
 * @returns true or false 
 */
function isAfterTime(dateTime, ms) {
    var d2 = new Date().getTime();
    if (d2 < (dateTime + ms)) {
        return false;
    }
    return true;
}