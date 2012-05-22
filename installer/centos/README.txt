= Redmine CentOS 版インストーラ
[[PageOutline(2,,inline)]]

== 0. はじめに
CentOS 版ではバイナリは i386 と x86_64 を作成する。またビルド環境は i386 と x86_64 とをそれぞれ準備する必要がある (クロスビルドできないため)。

== 1. 事前にインストールするもの
=== ビルドに必要なパッケージ
Yum からインストールします。

 i386::
    {{{
$ sudo yum install -y rpm-build.i386 gettext.i386 unzip.i386 \
    readline-devel.i386 ncurses-devel.i386 gdbm-devel.i386 openssl-devel.i386 \
    db4-devel.i386 zlib-devel.i386 libxml2-devel.i386 libxslt-devel.i386 \
    gcc-c++.i386 curl-devel.i386 httpd-devel.i386 apr-devel.i386 \
    apr-util-devel.i386 postgresql84-devel.i386 autoconf.noarch byacc.i386
    }}}
 x86_64::
    {{{
$ sudo yum install -y rpm-build.x86_64 gettext.x86_64 unzip.x86_64 \
    readline-devel.x86_64 ncurses-devel.x86_64 gdbm-devel.x86_64 \
    openssl-devel.x86_64 db4-devel.x86_64 zlib-devel.x86_64 \
    libxml2-devel.x86_64 libxslt-devel.x86_64 gcc-c++.x86_64 \
    curl-devel.x86_64 httpd-devel.x86_64 apr-devel.x86_64 \
    apr-util-devel.x86_64 postgresql84-devel.x86_64 autoconf.noarch \
    byacc.x86_64
    }}}

== 2. ビルド環境の作成
ビルドスクリプトは root 以外のユーザで実行するようになっているので専用ユーザを作成する。
以下の例では mockbuild ユーザを作成しています。
{{{
$ sudo /usr/sbin/useradd mockbuild
$ su - mockbuild
}}}

== 3. インストーラ作成
ソースの tarball を任意のディレクトリに配置・展開する。
展開後にある install/centos/ ディレクトリに移動し make コマンドを実行することで、
必要なファイルのダウンロード及びビルドが実行される。
i386 と x86_64 とで各々実行すること。

以下の例はソースを $HOME に配置したときのものです。
{{{
$ mkdir ~/src
$ tar xzf ~/ipf-redmine-installer-centos-r953.tgz -C ~/src
$ cd ~/src/ipf-redmine-installer-centos-r953/installer/centos
$ make
}}}
成功すれば build/ipftools-redmine-<version>-setup.<arch>.bin が作成される (<version>, <arch> はバージョンとアーキテクチャ名が入る)。

== A. ディレクトリ構成

|| `externals`                          || インストーラ生成以外のソースファイル (集計バッチ、Redmine プラグインなど) ||
|| `installer`                          || インストーラ用 ||
|| `installer/centos/build`             || rpmbuild のトップディレクトリ ||
|| `installer/centos/built`             || ビルド済みファイルが置かれるディレクトリ ||
|| `installer/centos/downloaded`        || ダウンロードしたファイルをここに配置するためのディレクトリ ||
|| `installer/centos/externals`         || インストーラ生成以外のソースファイル (集計バッチ、Redmine プラグインなど) ||
|| `installer/centos/files`             || 各アプリケーション設定ファイル (apache, birt, svn, など) ||
|| `installer/centos/installer`         || インストーラ実行時のスクリプトなど ||
|| `installer/centos/ipftools-redmine.spec.in` || ipftools-redmine パッケージの構成ファイル ||
|| `installer/centos/locale`            || インストーラ上のメッセージ翻訳ファイル ||
|| `installer/centos/Makefile`          || ビルド内容を記述 ||
|| `installer/centos/patches`           || 各ソースにあるファイルの差し替えをここにあるファイルで行う ||
|| `installer/centos/sysfiles`          || /etc ディレクトリに置くファイル ||
