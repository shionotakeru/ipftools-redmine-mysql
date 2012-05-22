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

package jp.go.ipa.ipf.sourcescale;

import java.util.Date;

/**
 * ソース規模データの収集結果を格納するクラス。
 */
public class SourceScaleResult {
	
	/**
	 * ファイル、ディレクトリの変更状況を示す列挙型
	 */
	public enum Status {
		NONE("変更なし"),
		ADDED("新規"),
		MODIFIED("変更"),
		REMOVED("削除"),
		UNSUPPORTED("サポート対象外");
		
        private String name;
        Status(String name) { this.name = name; }
        public String toString() { return name; }
	}

    /** リビジョン */
    private String revision;

    /** ファイルパス */
    private String filePath;

    /** ファイルパス（コピー元） */
    private String fileCopyPath;

    /** ファイル名 */
    private String fileName;

    /** ファイルの拡張子 */
    private String fileExt;

    /** ファイルの種類 */
    private String fileType;

    /** ステータス  */
    private Status status;

    /** 変更者 */
    private String author;

    /** 変更日時 */
    private Date updDate;

    /** メッセージ */
    private String message;

    /** ファイルサイズ */
    private long fileSize;

    /** 行数 */
    private long sourceLine;

    /** 行数２（空行、コメント行を除いた行数） */
    private long sourceLine2;

    /** 追加行数 */
    private long addLine;
    
    /** 追加行数２ */
    private long addLine2;
    
    /** 削除行数 */
    private long delLine;
    
    /** 削除行数２ */
    private long delLine2;
    
    /** 変更行数 */
    private long modLine;
    
    /** 変更行数２ */
    private long modLine2;
    
    /**
     * 変化行数
     * 前回リビジョンからの変化行数（削除された行数はマイナス値でカウント）
     */
    private long increaseLine;

    /** 変化行数２（空行、コメント行を除いた変化行数） */
    private long increaseLine2;

    /**
     * 変更行数
     * 前回リビジョンから変更行数（追加・変更・削除行数の総和）
     */
    private long changeLine;

    /** 変更行数２（空行、コメント行を除いた変更行数） */
    private long changeLine2;

    /**
     * リビジョンを取得します。
     * @return リビジョン
     */
    public String getRevision() {
        return revision;
    }

    /**
     * リビジョンを設定します。
     * @param revision リビジョン
     */
    public void setRevision(String revision) {
        this.revision = revision;
    }

    /**
     * ファイルパスを取得します。
     * @return ファイルパス
     */
    public String getFilePath() {
        return filePath;
    }

    /**
     * ファイルパスを設定します。
     * @param filePath ファイルパス
     */
    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    /**
     * ファイルの拡張子を取得します。
     * @return ファイルの拡張子
     */
    public String getFileExt() {
        return fileExt;
    }

    /**
     * ファイルの拡張子を設定します。
     * @param fileExt ファイルの拡張子
     */
    public void setFileExt(String fileExt) {
        this.fileExt = fileExt;
    }

    /**
     * ファイルの種類を取得します。
     * @return ファイルの種類
     */
    public String getFileType() {
        return fileType;
    }

    /**
     * ファイルの種類を設定します。
     * @param fileType ファイルの種類
     */
    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    /**
     * ソース規模収集可能な種類のファイルかどうかを返します。
     *
     * @return true:集計可能、false:集計不可
     */
    public boolean isCountable() {
        if (getFileType() != null) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * ステータスを取得します。
     * @return ステータス
     */
    public Status getStatus() {
        return status;
    }

    /**
     * ステータスを取得します。
     * @return ステータス
     */
    public String getStatusString() {
        if (status != null) {
            return status.toString();
        } else {
            return null;
        }
    }

    /**
     * ステータスを設定します。
     * @param status ステータス
     */
    public void setStatus(Status status) {
        this.status = status;
    }



    /**
     * ファイルパス（コピー元）を取得します。
     * @return ファイルパス（コピー元）
     */
    public String getFileCopyPath() {
        return fileCopyPath;
    }

    /**
     * ファイルパス（コピー元）を設定します。
     * @param fileCopyPath ファイルパス（コピー元）
     */
    public void setFileCopyPath(String fileCopyPath) {
        this.fileCopyPath = fileCopyPath;
    }

    /**
     * ファイル名を取得します。
     * @return ファイル名
     */
    public String getFileName() {
        return fileName;
    }

    /**
     * ファイル名を設定します。
     * @param fileName ファイル名
     */
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    /**
     * 変更者を取得します。
     * @return 変更者
     */
    public String getAuthor() {
        return author;
    }

    /**
     * 変更者を設定します。
     * @param author 変更者
     */
    public void setAuthor(String author) {
        this.author = author;
    }

    /**
     * 変更日時を取得します。
     * @return 変更日時
     */
    public Date getUpdDate() {
        return updDate;
    }

    /**
     * 変更日時を設定します。
     * @param updDate 変更日時
     */
    public void setUpdDate(Date updDate) {
        this.updDate = updDate;
    }

    /**
     * メッセージを取得します。
     * @return メッセージ
     */
    public String getMessage() {
        return message;
    }

    /**
     * メッセージを設定します。
     * @param message メッセージ
     */
    public void setMessage(String message) {
        this.message = message;
    }

    /**
     * ファイルサイズを取得します。
     * @return ファイルサイズ
     */
    public long getFileSize() {
        return fileSize;
    }

    /**
     * ファイルサイズを設定します。
     * @param fileSize ファイルサイズ
     */
    public void setFileSize(long fileSize) {
        this.fileSize = fileSize;
    }



	/**
	 * 行数を取得します。
	 * @return 行数
	 */
	public long getSourceLine() {
	    return sourceLine;
	}

	/**
	 * 行数を設定します。
	 * @param sourceLine 行数
	 */
	public void setSourceLine(long sourceLine) {
	    this.sourceLine = sourceLine;
	}

	/**
	 * 行数２（空行、コメント行を除いた行数）を取得します。
	 * @return 行数２（空行、コメント行を除いた行数）
	 */
	public long getSourceLine2() {
	    return sourceLine2;
	}

	/**
	 * 行数２（空行、コメント行を除いた行数）を設定します。
	 * @param sourceLine2 行数２（空行、コメント行を除いた行数）
	 */
	public void setSourceLine2(long sourceLine2) {
	    this.sourceLine2 = sourceLine2;
	}

	/**
	 * 追加行数を取得します。
	 * @return 追加行数
	 */
	public long getAddLine() {
	    return addLine;
	}

	/**
	 * 追加行数を設定します。
	 * @param addLine 追加行数
	 */
	public void setAddLine(long addLine) {
	    this.addLine = addLine;
	}

	/**
	 * 追加行数２を取得します。
	 * @return 追加行数２
	 */
	public long getAddLine2() {
	    return addLine2;
	}

	/**
	 * 追加行数２を設定します。
	 * @param addLine2 追加行数２
	 */
	public void setAddLine2(long addLine2) {
	    this.addLine2 = addLine2;
	}

	/**
	 * 削除行数を取得します。
	 * @return 削除行数
	 */
	public long getDelLine() {
	    return delLine;
	}

	/**
	 * 削除行数を設定します。
	 * @param delLine 削除行数
	 */
	public void setDelLine(long delLine) {
	    this.delLine = delLine;
	}

	/**
	 * 削除行数２を取得します。
	 * @return 削除行数２
	 */
	public long getDelLine2() {
	    return delLine2;
	}

	/**
	 * 削除行数２を設定します。
	 * @param delLine2 削除行数２
	 */
	public void setDelLine2(long delLine2) {
	    this.delLine2 = delLine2;
	}

    /**
	 * 変更行数を取得します。
	 * @return 変更行数
	 */
	public long getModLine() {
	    return modLine;
	}

	/**
	 * 変更行数を設定します。
	 * @param modLine 変更行数
	 */
	public void setModLine(long modLine) {
	    this.modLine = modLine;
	}

	/**
	 * 変更行数２を取得します。
	 * @return 変更行数２
	 */
	public long getModLine2() {
	    return modLine2;
	}

	/**
	 * 変更行数２を設定します。
	 * @param modLine2 変更行数２
	 */
	public void setModLine2(long modLine2) {
	    this.modLine2 = modLine2;
	}

	/**
	 * 変化行数を取得します。
	 * @return 変化行数
	 */
	public long getIncreaseLine() {
	    return increaseLine;
	}

	/**
	 * 変化行数を設定します。
	 * @param increaseLine 変化行数
	 */
	public void setIncreaseLine(long increaseLine) {
	    this.increaseLine = increaseLine;
	}

	/**
	 * 変化行数２（空行、コメント行を除いた変化行数）を取得します。
	 * @return 変化行数２（空行、コメント行を除いた変化行数）
	 */
	public long getIncreaseLine2() {
	    return increaseLine2;
	}

	/**
	 * 変化行数２（空行、コメント行を除いた変化行数）を設定します。
	 * @param increaseLine2 変化行数２（空行、コメント行を除いた変化行数）
	 */
	public void setIncreaseLine2(long increaseLine2) {
	    this.increaseLine2 = increaseLine2;
	}

	/**
	 * 変更行数を取得します。
	 * @return 変更行数
	 */
	public long getChangeLine() {
	    return changeLine;
	}

	/**
	 * 変更行数を設定します。
	 * @param changeLine 変更行数
	 */
	public void setChangeLine(long changeLine) {
	    this.changeLine = changeLine;
	}

	/**
	 * 変更行数２（空行、コメント行を除いた変更行数）を取得します。
	 * @return 変更行数２（空行、コメント行を除いた変更行数）
	 */
	public long getChangeLine2() {
	    return changeLine2;
	}

	/**
	 * 変更行数２（空行、コメント行を除いた変更行数）を設定します。
	 * @param changeLine2 変更行数２（空行、コメント行を除いた変更行数）
	 */
	public void setChangeLine2(long changeLine2) {
	    this.changeLine2 = changeLine2;
	}

	/**
     * 収集結果を文字列で取得します
     * @return カウント結果の文字列
     */
    public String getResultString(){
        StringBuffer sb = new StringBuffer();
        sb.append("リビジョン:" + getRevision() + " ");
        sb.append("ファイルパス:" + getFilePath() + " ");
        sb.append("ファイル名:" + getFileName() + " ");
        sb.append("ファイル拡張子:" + getFileExt() + " ");
        sb.append("更新者:" + getAuthor() + " ");
        sb.append("更新日時:" + getUpdDate() + " ");
        sb.append("変更状況:" + getStatusString() + " ");
        sb.append("ファイル種類:" + getFileType() + " ");
        sb.append("サイズ:" + getFileSize() + " ");
        sb.append("行数:" + getSourceLine() + " ");
        sb.append("行数２:" + getSourceLine2() + " ");
        sb.append("変化行数:" + getIncreaseLine() + " ");
        sb.append("変化行数２:" + getIncreaseLine2() + " ");
        sb.append("変更行数:" + getChangeLine() + " ");
        sb.append("変更行数２:" + getChangeLine2() + " ");
        return sb.toString();
    }
    
	/**
     * 収集結果（詳細）を文字列で取得します
     * @return カウント結果の文字列
     */
    public String getResultDetailString(){
    	
    	StringBuffer sb = new StringBuffer(this.getResultString());
        sb.append("追加行数:" + getAddLine() + " ");
        sb.append("追加行数２:" + getAddLine2() + " ");
        sb.append("削除行数:" + getDelLine() + " ");
        sb.append("削除行数２:" + getDelLine2() + " ");
        sb.append("変更行数:" + getModLine() + " ");
        sb.append("変更行数２:" + getModLine2() + " ");
        return sb.toString();
        
    }

}
