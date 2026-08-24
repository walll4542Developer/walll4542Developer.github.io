# 낭낭하게 개발하기

Jekyll 없이 제공되는 순수 정적 HTML 블로그입니다. GitHub Pages는 저장소 루트를 그대로 제공하며, 게시글 URL과 기존 `/assets/` 경로를 유지합니다.

## 수정 위치

- `content/site.json`: 사이트 제목, 프로필, 소셜 링크, PWA, 페이지당 글 수
- `content/posts/`: 게시글 Markdown과 Front Matter
- `content/pages/about.md`: 소개 페이지
- `assets/`: 이미지, 다운로드 파일, 스타일과 브라우저 JavaScript

`posts/`, `categories/`, `tags/`, `archives/`, `feed.xml`, `sitemap.xml`, 검색 색인은 생성 결과입니다. 직접 고치지 말고 콘텐츠를 수정한 뒤 생성하세요.

## 글 작성과 생성

Node.js 22 이상과 pnpm이 필요합니다.

```sh
pnpm install --frozen-lockfile
pnpm run build
pnpm run check
```

새 글은 `content/posts/YYYY-MM-DD-Title.md` 형식으로 작성합니다. 최소 Front Matter는 다음과 같습니다.

```md
---
title: "글 제목"
excerpt: "목록과 검색에 표시할 요약"
date: 2026-08-24 09:00:00 +0900
categories: [Research]
tags: [Shader]
---
```

생성 명령은 HTML 페이지, 태그·카테고리·보관함, RSS, sitemap, 검색 색인, 캐시를 모두 갱신합니다. 생성 결과까지 함께 커밋해야 GitHub Pages에 반영됩니다.
