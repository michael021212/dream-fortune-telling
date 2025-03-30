# README

LINEで夢の内容を送信するとAI(Gemini)による解釈を返信してくれるサービス
Cloud Run + Cloud Storage

```
Ruby 3.4.2
Rails 8.0.2
SQLite3
```

<img src="https://github.com/user-attachments/assets/0d14585f-34d2-4b91-abd2-075d2c198c48" width="500">


### デプロイ
```
// イメージのビルドとプッシュ
docker build --platform=linux/amd64 -t asia-northeast1-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$SERVICE_NAME:1 .
docker push asia-northeast1-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$SERVICE_NAME:1

// Cloud Runの「新しいリビジョンの編集とデプロイ」からデプロイ
https://console.cloud.google.com/run/detail/asia-northeast1/dream-fortune-telling/revisions?project=dream-fortune-telling&inv=1&invt=AbtYkA
```
