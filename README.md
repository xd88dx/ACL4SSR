# Sub-Config

```shell
diff -u --strip-trailing-cr rename_remote.js rename_update.js > patch_rename.diff

cp rename_remote.js rename_remote.js.bak
mv rename_update.js rename_update.js.bak

patch rename_remote.js < patch_rename.diff
```
