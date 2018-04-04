# frp-one-click-ByWIJ
## 使用平台ubuntu、Centos 7、Raspberry Pi 3
## 本工具可以搭建Server端和Client端
## 內容如下
<br>
(1).安裝frp<br>
  相關的安裝位置為/root/frp，如果想要重新安裝的話，再安裝一次就行了<br>
  <br>
(2).啟動frp<br>
  使用腳本啟動<br>
  使用nohup /root/frp/frps -c /root/frp/frpc & 方式<br>
  <br>
(3).停止frp<br>
  使用腳本停止<br>
  使用killall方式<br>
  <br>
(4).將frp加入開機啟動<br>
  預設使用systemctl 方式 加入開機自啟<br>
  如果沒有systemctl的話 將會使用service來加入開機自啟<br>
  <br>
(5).編輯frp設定檔<br>
<br>
(6).查看frp log檔<br>
<br>
(7).解除安裝frp<br>
<br>
(8).離開<br>
