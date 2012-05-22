#[定量的プロジェクト管理ツール](http://sec.ipa.go.jp/tool/ipf/index.html)


##ツールの概要
  IT利用度がかつて無いほどに高まってきており、情報システムの障害による業務・サービスの停止や機能低下の社会的影響が深刻化しています。一方、ソフトウェア開発の短納期化・低コスト化はさらに進んできています。そのため、ソフトウェアの品質の確保や、納期の遵守のためには、検出不具合数や工数の進捗具合などプロジェクト進行過程において測定する定量的なデータを用いて品質や進捗の状況を適切に把握することで、リスクを可視化し、問題を早期に発見する定量的プロジェクト管理が求められています。

  IPA/SECでは、主にプロジェクト・マネージャを対象に、ソフトウェア開発プロジェクトの定量的プロジェクト管理を支援する「定量的プロジェクト管理ツール」を公開しています。

##ツールの特徴
  ソフトウェア開発プロジェクトの定量的管理を行うプロジェクト・マネージャを支援するため、進行中の開発プロジェクトからプロジェクトデータを取得し管理する「プロジェクト管理機能」、プロジェクトデータから基本的な定量データ（規模、工数、工期）を自動収集・集計し、グラフデータを作成する「データ収集・集計機能」、グラフデータを表示する「分析レポーティング機能」を提供しています。

  また、本ツールは、既存のオープンソフトウェアを基盤アプリケーションとして利用しています。プロジェクト管理ツールとしてはRedmine,Trac、構成管理ツールとしてはSubversion,GIT、ETLツールとしてはPentaho、グラフ表示ツールとしてはEclipse BIRT/BIRT Report Viewerを使用して構築されています。本ツール自体もフリーソフトウェアライセンス（GPL:GNU General Public License）として公開します。

*    容易な導入と利用

    「定量的プロジェクト管理ツール」は、なるべく容易に導入や利用ができることを優先しているため、基本的な定量データ（ソース規模、工数、進捗、品質等）を自動収集し、グラフ化することによるプロジェクト管理の支援に焦点を絞っています。

    また、利用しているツール群をひとつのパッケージとして作成しているので、インストール後、すぐに使用できます。


*    グラフによるレポーティング

    各定量データを収集・集計した結果をグラフとして表示します。これによりデータ分析を行うことなく、定量データによる状況の把握を視覚的・直観的に行うことができます。

*    定量データの自動収集

    プロジェクト管理ツール（Redmine, Trac）の日次データ（チケット・データ）から自動的に定量データの収集・生成を行うことにより開発担当者の負荷軽減を図っています。また、構成管理ツールとしてRedmine、Tracと親和性の高いSubversion、GITを利用し、プログラムの変更情報を自動的に収集して負荷軽減を図っています。

*    データの可用性

    チケット・データとExcel、MS Project、CSV形式データとの相互変換機能（データのインポート、エクスポート機能）を提供しています。これにより、既に使用しているExcel、MS Projectや他管理ツールとのデータ連携が可能となります。

    また、グラフデータの可用性を高めるため、グラフのファイル出力を提供しています。PDF、Word、 PowerPoint形式の文書としてグラフを保存、編集して報告書を作成する等にグラフを活用することができます。