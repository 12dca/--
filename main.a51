
FALL_TIME_L DATA 51H       ;倒计时计时低8位
FALL_TIME_H DATA 52H       ;倒计时计时高8位
TIME_L DATA 53H       ;计时低8位
TIME_H DATA 54H       ;计时高8位
TIME_WEEK DATA 56H       ;星期存放单元
TIME_WEEK_1 DATA 5CH ;年份低两位存放单元(BCD码)
TIME_WEEK_2 DATA 5DH ;年份低两位存放单元(BCD码)
TIME_WEEK_3 DATA 5EH ;月份存放单元(BCD码)
TIME_WEEK_4 DATA 5FH ;日存放单元(BCD码)
TIME_WEEK_5 DATA 55H ;日存放单元(BCD码)

TEMP_BYTE1 DATA 57H
TEMP_BYTE2 DATA 58H
TEMP_BYTE3 DATA 59H
TEMP_BYTE4 DATA 5AH
UPRIGHT_TIME_FLAG DATA 5BH    ;正计时标志位
TIME_ADJUST_MODE DATA 50H     ;模式选择
TIME_FALL_FLAG BIT 20H.1      ;倒计时标志位
UPRIGHT_TIME_NUMBER DATA 3FH  ;正计时多段时间记录的数量
TIME_H_3 DATA 3EH             ;3个正计时节点记录
TIME_L_3 DATA 3DH 	
TIME_H_2 DATA 2CH       
TIME_L_2 DATA 2BH 
TIME_H_1 DATA 2AH       
TIME_L_1 DATA 29H       
TIME_ADJUST_FLAG DATA 28H    ;闪烁标志   
TIME_DELAY_FLAG DATA 27H
YEARH DATA 26H ;年份高两位
YEARL DATA 25H ;年份低两位存放单元(BCD码)
MONTH DATA 24H ;月份存放单元(BCD码)
DAY DATA 23H ;日存放单元(BCD码)
HOUR DATA 22H ;时存放单元(BCD码)
MINUTE DATA 21H ;分存放单元(BCD码)
SEC DATA 20H ;秒存放单元(BCD码)
TIMES DATA 11H
; DS1302引脚定义
RST    BIT P1.2      ; 复位引脚
SCLK   BIT P1.7      ; 串行时钟
IO     BIT P2.7      ; 数据线

TIME_ADJUST BIT P3.1
ADD_ONE BIT P3.2
DEC_ONE BIT P3.3
ADD_SITE BIT P3.4
SITE_MODE BIT P3.5
SITE_MODE2 BIT P3.6
LCD_RS BIT P1.0
LCD_RW BIT P1.1
LCD_E BIT P2.5
BUZZER BIT P2.3
LCD_DATA EQU P0
MODE_NUMBER EQU 3
READ_SEC   EQU 0x81   ; 读秒
READ_MIN   EQU 0x83   ; 读分
READ_HOUR  EQU 0x85   ; 读时
READ_DAY   EQU 0x87   ; 读日
READ_MONTH EQU 0x89   ; 读月
READ_WEEK  EQU 0x8B   ; 读星期
READ_YEAR  EQU 0x8D   ; 读年
;bz1 BIT 21H.0
;time_adjust_flag BIT 20H
ORG 0000H          ;程序执行开始地址
LJMP  START  ;跳到标号START执行
ORG 0030H 
;ORG 0003H          ;外中断0中断程序入口
;RETI                     ;外中断0中断返回
ORG 000BH        ;定时器T0中断程序入口
;LJMP  INTT0  ;跳至INTTO执行
;ORG 0013H        ;外中断1中断程序入口
;RETI                   ;外中断1中断返回
ORG 001BH        ;定时器T1中断程序入口
LJMP  INTT1  ;跳至INTTO执行
;RETI
;ORG 0023H        ;串行中断程序入口地址
;RETI                    ;串行中断程序返回
START:               ;主 程 序  
     
     MOV R0,#20H
     MOV R7,#16
     CLEETE:
     MOV @R0,#00H
     INC R0
     DJNZ R7,CLEETE
	 MOV SP,#60H
	 MOV TIME_ADJUST_FLAG,#0
	 MOV TIME_ADJUST_MODE,#0
	 SETB TIME_FALL_FLAG
;     MOV TIMES,#00H ;清调时标志
     MOV TMOD,#11H ;设T0为16位定时器    计时用）
     MOV TH0,#63H ;40MS定时初值
     MOV TL0,#0C0H ;40MS定时初值（T0
	 MOV TH1, #0D8H       ; 高位
     MOV TL1, #0F0H       ; 低位
	 
	  ; 初始化IO口: 将IO设为输入(置1)
     SETB    IO
     CLR     SCLK
     CLR     RST
	 SETB EA    ;开启总中断
;	 SETB ET0    ;开启定时器中断
	 SETB ET1    ;开启定时器中断
;	 SETB TR0    ;启动定时器
	 SETB PT1    ; 定时器1高优先级
	 MOV R4,#19H
	 CALL LCD_INIT
	 MOV DPTR,#SITE_DATA  //设置调整地址
	 MOV TIME_DELAY_FLAG,#0FH
	 MOV YEARH,#20H
	 MOV YEARL,#26H
	 MOV MONTH,#01H
	 MOV DAY,#06H
	 MOV TIME_H,#0
	 MOV TIME_L,#0
	 MOV R2,#10H
	 MOV R3,#0
	 MOV FALL_TIME_L,R3
	 MOV FALL_TIME_H,R2
	 MOV UPRIGHT_TIME_NUMBER,#0
	 MOV UPRIGHT_TIME_FLAG,#0
	 LCALL DS1302_Enable_Write
	 MOV     R7, #85H
     LCALL   DS1302_READ
	 MOV     HOUR, A              ; 保存到时寄存器
	 MOV     R7, #84H
	 MOV     A, HOUR       ; 取出当前小时值
     ANL     A, #7FH       ; 清除最高位，保留低8位中的低7位
     MOV     R6, A         ; 将处理后的值存入R6
     LCALL   DS1302_WRITE
	 LCALL   DS1302_Disable_Write         ; 禁止写入操作
	 MAIN:
	 MOV A,TIME_ADJUST_FLAG
     CJNE A,#0,main1
	 CALL GET_TIME
	 SJMP main2
	 main1:
	 LCALL WRITE_ALL_TIME
	 main2:
	 CALL WEEK   //算出星期
	 CALL SHOW   //显示
	 CALL KEY_SCAN  //按键逻辑控制
	 LJMP  MAIN
	 
GET_TIME:
    MOV     R7, #81H
    LCALL   DS1302_READ
	MOV     SEC, A              ; 保存到秒寄存器
	MOV     R7, #83H
    LCALL   DS1302_READ
	MOV     MINUTE, A              ; 保存到分寄存器
	MOV     R7, #85H
    LCALL   DS1302_READ
	MOV     HOUR, A              ; 保存到时寄存器
	MOV     R7, #89H           ; 读取月寄存器
    LCALL   DS1302_READ
	MOV     MONTH, A              ; 保存到月份单元
	MOV     R7, #87H           ; 读取日寄存器
    LCALL   DS1302_READ
	MOV     DAY, A               ; 保存到日单元
	MOV     R7, #8DH
    LCALL   DS1302_READ
	MOV     YEARL, A              ; 保存到年寄存器
	RET
WRITE_ALL_TIME:
     LCALL DS1302_Enable_Write
     MOV     R7, #80H
     MOV     R6, SEC         
     LCALL   DS1302_WRITE
	 MOV     R7, #82H
     MOV     R6, MINUTE       
     LCALL   DS1302_WRITE
	 MOV     R7, #84H
     MOV     R6, HOUR        
     LCALL   DS1302_WRITE
	 MOV     R7, #88H          ; 写月寄存器
     MOV     R6, MONTH
     LCALL   DS1302_WRITE
	 MOV     R7, #86H          ; 写日寄存器
     MOV     R6, DAY
     LCALL   DS1302_WRITE
	 MOV     R7, #8CH
     MOV     R6, YEARL         
     LCALL   DS1302_WRITE
	 LCALL   DS1302_Disable_Write         ; 禁止写保护
	 RET
DS1302_Enable_Write:
    CLR     RST
    CLR     SCLK
    MOV     R7, #8EH
    MOV     R6, #00H
    LCALL   DS1302_WRITE
    RET	 
DS1302_Disable_Write:
    CLR     RST
    CLR     SCLK
    MOV     R7, #8EH
    MOV     R6, #80H
    LCALL   DS1302_WRITE
    RET	 
; BCD 码转十进制 (二进制) 子程序
; 入口: A = BCD 码 (如 0x35)
; 出口: A = 十进制数值 (如 35)
; 原理: 十位*10 + 个位
;--------------------------------------------------------------------
BCD_TO_DEC:
    PUSH    B
    MOV     B, A
    ANL     A, #0FH         ; 取个位
    MOV     R2, A
    MOV     A, B
    SWAP    A
    ANL     A, #0FH         ; 取十位
    MOV     B, #10
    MUL     AB
    ADD     A, R2
    POP     B
    RET
;------------------------------------------------------
; 向DS1302指定命令地址写入一个字节 (命令在A中)
; 返回数据在A中
;------------------------------------------------------
DS1302_READ:
    CLR     RST
    CLR     SCLK
    SETB    RST
    MOV     A, R7           ; 命令地址
    LCALL   DS1302_WRITE_BYTE
    SETB    IO              ; 切换 IO 为输入（51单片机需要先写 1）
    LCALL   DS1302_READ_BYTE
    CLR     SCLK
    CLR     RST
    RET

; 从 DS1302 指定地址读取一个数据字节
; 入口：R7 = 命令地址（如 0x81 读秒）
; 出口：A = 读出的数据
;------------------------------------------------
DS1302_WRITE:
    CLR     RST
    CLR     SCLK
    SETB    RST
    MOV     A, R7           ; 命令地址
    LCALL   DS1302_WRITE_BYTE
    MOV     A, R6           ; 数据字节
    LCALL   DS1302_WRITE_BYTE
    CLR     SCLK
    CLR     RST
    RET
; 向 DS1302 写入一个字节（低位先）
DS1302_WRITE_BYTE:
    PUSH    ACC
    MOV     R7, #8          ; 8 位循环
WB_LOOP:
    CLR     SCLK            ; 时钟拉低
    RRC     A               ; 最低位移至 CY
    MOV     IO, C           ; 输出该位
    SETB    SCLK            ; 时钟上升沿，DS1302采样
    DJNZ    R7, WB_LOOP
    POP     ACC
    RET
;从DS1302读取一个字节 (返回数据在A中)	 
DS1302_READ_BYTE:
    PUSH  B
    MOV   R6, #8
    MOV   B, #0
RB_LOOP:
    SETB  SCLK             ; 拉高时钟，准备
    NOP
	NOP
    CLR   SCLK             ; ★ 下降沿: DS1302在此刻改变IO引脚数据
	NOP
    NOP
    MOV   C, IO            ; 立即读取稳定的数据
    MOV   A, B
    RRC   A                ; 将读入的位放入ACC的低位
    MOV   B, A
    DJNZ  R6, RB_LOOP
    MOV   A, B
    POP   B
    RET

INTT1:
     PUSH ACC
	 PUSH PSW
	 PUSH 00H
	 PUSH 05H
	 PUSH 06H
	 PUSH 07H
	 PUSH 0F0H       ; 保存B
	 MOV TH1, #0D8H       ; 高位
     MOV TL1, #0F0H       ; 低位
	 
	 MOV A,TIME_ADJUST_MODE   //读取模式
     CJNE A,#1,ZD22;   
	 
	 MOV A,TIME_L  //正计时
	 ADD A,#1
	 MOV B,A
	 DA A ;十进制调整
	 MOV TIME_L,A
	 MOV A,B
	 
	 CJNE A,#9AH,ZD11 ;
	 MOV TIME_L,#0
	 MOV A,TIME_H
	 ADD A,#1
	 DA A
	 MOV TIME_H,A
	 SJMP ZD11
	 
	 ZD22:    //倒计时
	 MOV A,FALL_TIME_L
	 ADD A, #99H       ; 相当于减1
	 DA A ;十进制调整
	 MOV FALL_TIME_L,A
	 JNC ZD33 ;
	 SJMP ZD44
	 ZD33:
	 MOV A,FALL_TIME_H
	 ADD A, #99H       ; 相当于减1
	 DA A
	 MOV FALL_TIME_H,A
	 SJMP ZD44
	 
	 ZD44:
	 MOV R5,FALL_TIME_L
	 MOV R6,FALL_TIME_H
	 CJNE R6,#00H,ZD11
	 CJNE R5,#00H,ZD11
	 CLR TR1           //关闭定时器，蜂鸣器响
	 CLR BUZZER
	 SJMP ZD11
     ZD11:
	 POP 0F0H       ; 出B
	 POP 07H
	 POP 06H
	 POP 05H
	 POP 00H
	 POP PSW
	 POP ACC
	 RETI

KEY_SCAN:
     DEC TIME_DELAY_FLAG
     MOV A,TIME_DELAY_FLAG
	 JNZ KEY1    //TIME_DELAY_FLAG不等于0跳转
	 WUYU:       //闪烁
	 MOV TIME_DELAY_FLAG,#03H
;	 JNB TIME_ADJUST_FLAG,KEY1
     MOV A,TIME_ADJUST_FLAG
     CJNE A,#1,KEY1
	 CLR A
	 MOVC A,@A+DPTR
	 MOV LCD_DATA,A
	 CALL LCD_WRITE_CMD
	 MOV LCD_DATA,#' '
	 CALL LCD_WRITE_DATA
	 
	 
     KEY1:
     MOV   C, TIME_ADJUST      ; 读取按键状态
     JC    KEY2       ; 如果C=1（按键未按下），跳转
     MOV R0,#20
	 DELAY_S0:
	 CALL DELAY_1MS
     DJNZ R0,DELAY_S0
     MOV   C, TIME_ADJUST      ; 再次检测
     JC    KEY2       ; 如果是抖动，跳转
	 KEY_WAIT_RELEASE0:
     
     MOV   C, TIME_ADJUST
     JNC   KEY_WAIT_RELEASE0    ; 如果还是低电平，继续等待
     
     MOV A,TIME_ADJUST_MODE
     CJNE A,#0,KEY1_1;
	 MOV DPTR,#SITE_DATA     //模式1
;	 CPL TIME_ADJUST_FLAG
     INC TIME_ADJUST_FLAG
     MOV B,#2
	 MOV A,TIME_ADJUST_FLAG
	 DIV AB
	 MOV TIME_ADJUST_FLAG,B
	 CPL TR0
	 SJMP KEY2
	 
	 KEY1_1:
     CJNE A,#1,KEY1_2;
	 MOV TIME_L,#0         //正计时清零
	 MOV TIME_H,#0
;	 MOV UPRIGHT_TIME_NUMBER,#0
	 SJMP KEY2
;	 INC YEARL
     KEY1_2:
	 MOV DPTR,#SITE_DATA  //倒计时选择位置进行调整
	 INC DPTR
;	 CPL TIME_ADJUST_FLAG2
     INC TIME_ADJUST_FLAG
     MOV B,#2
	 MOV A,TIME_ADJUST_FLAG
	 DIV AB
	 MOV TIME_ADJUST_FLAG,B
	 SJMP KEY2
	 
	 KEY2:
     MOV   C, ADD_ONE      ; 读取按键状态
     JC    KEY3       ; 如果C=1（按键未按下），跳转
     MOV R0,#20       
	 DELAY_S1:
	 CALL DELAY_1MS
     DJNZ R0,DELAY_S1
     MOV   C, ADD_ONE      ; 再次检测
     JC    KEY3       ; 如果是抖动，跳转
	 KEY_WAIT_RELEASE1:
     MOV   C, ADD_ONE
     JNC   KEY_WAIT_RELEASE1    ; 如果还是低电平，继续等待
;	 JNB TIME_ADJUST_FLAG,KEY_END
     MOV A,TIME_ADJUST_FLAG  //
     CJNE A,#1,KEY2_2  
	 MOV A,TIME_ADJUST_MODE
	 CJNE A,#0,KEY2_1
	 CALL INC_ONE      //模式1加1
	 SJMP KEY3
	 KEY2_1:           //模式3加1
	 CALL FALL_INC_ONE
	 SJMP KEY3
	 KEY2_2:   //模式2的多段计时记录
	 MOV B,#3
	 MOV A,UPRIGHT_TIME_NUMBER
	 DIV AB
	 MOV UPRIGHT_TIME_NUMBER,B
	 MOV A, B                   
     ADD A, ACC
	 ADD A,#TIME_H_1
	 MOV R0,A
	 MOV A, TIME_H
     MOV @R0, A
	 DEC R0
	 MOV A, TIME_L
     MOV @R0, A 
     MOV A,UPRIGHT_TIME_NUMBER	 
	 INC UPRIGHT_TIME_NUMBER
	 	 	 	 
	 KEY3:
	 MOV   C, DEC_ONE      ; 读取按键状态
     JC    KEY4       ; 如果C=1（按键未按下），跳转
     MOV R0,#20
	 DELAY_S2:
	 CALL DELAY_1MS
     MOV   C, DEC_ONE      ; 再次检测
     DJNZ R0,DELAY_S2
     JC    KEY4       ; 如果是抖动，跳转
	 KEY_WAIT_RELEASE2:
     MOV   C, DEC_ONE
     JNC   KEY_WAIT_RELEASE2    ; 如果还是低电平，继续等待
	 JNB BUZZER,KEY3_1 ;BUZZER=0跳转
	 CPL TR1    //暂停
	 SJMP KEY4
	 KEY3_1:    //倒计时到零后恢复
	 SETB BUZZER
	 MOV FALL_TIME_L,R3
	 MOV FALL_TIME_H,R2
	 SJMP KEY4
	 
	 KEY4:
	 MOV   C, ADD_SITE      ; 读取按键状态
     JC    KEY5       ; 如果C=1（按键未按下），跳转
     MOV R0,#20
	 DELAY_S3:
	 CALL DELAY_1MS
     MOV   C, ADD_SITE      ; 再次检测
     DJNZ R0,DELAY_S3
     JC    KEY5       ; 如果是抖动，跳转
	 KEY_WAIT_RELEASE3:
     MOV   C, ADD_SITE
     JNC   KEY_WAIT_RELEASE3    ; 如果还是低电平，继续等待
     
     MOV A,TIME_ADJUST_MODE
     CJNE A,#0,KEY4_1
	 
	 CLR A    //模式1的闪烁位置调整
	 MOVC A,@A+DPTR
	 CJNE A, #0X80,RETURN_SITE
	 MOV DPTR,#SITE_DATA
	 SJMP KEY_END
	 
	 KEY4_1:  //模式3的闪烁位置调整
	 CJNE A,#2,KEY4_2
	 CLR A
	 MOVC A,@A+DPTR
	 CJNE A, #0XC3,RETURN_SITE
	 MOV DPTR,#SITE_DATA
	 INC DPTR
	 SJMP KEY_END
	 
	 KEY4_2:  //模式2的记录的数据切换
	 MOV LCD_DATA,#0X01
	 CALL LCD_WRITE_CMD 
	 INC UPRIGHT_TIME_FLAG
	 MOV B,#4
	 MOV A,UPRIGHT_TIME_FLAG
	 DIV AB
	 MOV UPRIGHT_TIME_FLAG,B

     
	 KEY5:
	 MOV   C, SITE_MODE      ; 读取按键状态
     JC    KEY_END       ; 如果C=1（按键未按下），跳转
     MOV R0,#20
	 DELAY_S4:
	 CALL DELAY_1MS
     MOV   C, SITE_MODE      ; 再次检测
     DJNZ R0,DELAY_S4
     JC    KEY_END       ; 如果是抖动，跳转
	 KEY_WAIT_RELEASE4:
     MOV   C, SITE_MODE
     JNC   KEY_WAIT_RELEASE4    ; 如果还是低电平，继续等待
     
	 MOV LCD_DATA,#0X01       //模式切换
	 CALL LCD_WRITE_CMD
	 MOV TIME_ADJUST_FLAG,#0
	 SETB TR0
	 MOV TIME_H,#0
	 MOV TIME_L,#0
	 MOV FALL_TIME_L,R3
	 MOV FALL_TIME_H,R2
	 CLR TR1
	 MOV TH1, #0D8H       ; 高位
     MOV TL1, #0F0H       ; 低位
	 SETB BUZZER
	 INC TIME_ADJUST_MODE
	 MOV B,#MODE_NUMBER
	 MOV A,TIME_ADJUST_MODE
	 DIV AB
	 MOV TIME_ADJUST_MODE,B
	 
	 MOV UPRIGHT_TIME_NUMBER,#0
	 MOV UPRIGHT_TIME_FLAG,#0
	 
	 MOV R0,#39H
     MOV R7,#7
     CLEETE1:
     MOV @R0,#00H
     INC R0
     DJNZ R7,CLEETE1
	 SJMP KEY_END
	 
	 RETURN_SITE:
	 INC DPTR
	 
	 KEY_END:
     RET
FALL_INC_ONE:
     CLR A
	 MOVC A,@A+DPTR
	 CJNE A, #0XC6,FALL_INC_ONE11
	 MOV A,FALL_TIME_L
	 ADD A,#1
	 DA A ;十进制调整
	 MOV FALL_TIME_L,A
	 
	 FALL_INC_ONE11:
	 CJNE A, #0XC3,FALL_INC_ONE_END
	 MOV A,FALL_TIME_H
	 ADD A,#1
	 DA A ;秒调整
	 MOV FALL_TIME_H,A
	 FALL_INC_ONE_END:
	 MOV R3,FALL_TIME_L
	 MOV R2,FALL_TIME_H
	 RET
INC_ONE:    
     CLR A
	 MOVC A,@A+DPTR
	 CJNE A, #0XC9,INC_ONE000
	 MOV A,SEC
	 ADD A,#1
	 DA A ;秒调整
	 MOV SEC,A
	 CJNE A,#60H,INC_ONE888 ;秒溢出
	 MOV SEC,#0
     INC_ONE000:
	 CJNE A, #0XC6,INC_ONE001
	 MOV A,MINUTE
	 ADD A,#1
	 DA A ;
	 MOV MINUTE,A
	 INC_ONE888:
	 CJNE A,#60H,INC_ONE_END ;分溢出
	 MOV MINUTE,#0
	 SJMP INC_ONE_END
	 INC_ONE001:
     CJNE A, #0XC3,INC_ONE002
	 MOV A,HOUR
	 ADD A,#1
	 DA A ;
	 MOV HOUR,A
	 CJNE A,#24H,INC_ONE_END ;时溢出
	 MOV HOUR,#0
	 SJMP INC_ONE_END
	 INC_ONE002:
     CJNE A, #0X89,INC_ONE003
	 MOV A,DAY
	 ADD A,#1
	 DA A ;
	 MOV DAY,A
	 
	 MOV A,MONTH    ;查询本月最大日期
	 INC A
	 MOVC A,@A+PC
	 SJMP INC_ONE010
	 DB 31H,28H,31H       ;对应月份编码:01H,02H,03H
	 DB 30H,31H,30H       ;对应月份编码:04H,05H,06H
	 DB 31H,31H,30H       ;对应月份编码:07H,08H,09H
	 DB 00H,00H,00H       ;对应无效月份编码:0AH,0BH,0CH\n
	 DB 00H,00H,00H       ;对应无效月份编码:0DH,0EH,0FH\n
	 DB 31H,30H,31H       ;对应月份编码:10H,11H,12H
	 
	 INC_ONE010:
	 CLR   C
	 SUBB  A,DAY
	 JNC   INC_ONE_END                ;本月未满
	 MOV   A,MONTH
	 CJNE  A,#2,INC_ONE012       ;是否二月
	 MOV   A,YEARL
	 ANL   A,#13H           ;保留年份中非4的整数部分
	 JNB   ACC.4,INC_ONE011
	 ADD   A,#2
	 INC_ONE011:
	 ANL   A,#3             ;能否被4整除
	 JNZ   INC_ONE012             ;非闰年
	 MOV   A,DAY
	 XRL   A,#29H
	 JZ    INC_ONE_END              ;闰年二月可以有29日
	 INC_ONE012:
	 MOV   DAY,#1          ;调整到下个月的1日	 
	 SJMP INC_ONE_END
	 
	 INC_ONE003:
     CJNE A, #0X86,INC_ONE004
	 MOV A,MONTH
	 ADD A,#1
	 DA A ;
	 MOV MONTH,A
	 CJNE A,#13H,INC_ONE_END ;月溢出
	 MOV MONTH,#1
	 SJMP INC_ONE_END
	 
	 INC_ONE004:
     CJNE A, #0X83,INC_ONE_END
	 MOV A,YEARL
	 ADD A,#1
	 DA A ;
	 MOV YEARL,A
	 
	 SJMP INC_ONE_END
	 INC_ONE_END: 
	 RET
;INTT0:
;	 PUSH ACC
;	 PUSH PSW
;	 PUSH 00H
;	 PUSH 05H
;	 PUSH 06H
;	 PUSH 07H
;	 MOV TL0,#0C0H ;
;     MOV TH0,#63H ;重置
;	 
;	 DJNZ R4,CLKE111
;	 MOV R4,#19H
;	 MOV A,SEC
;	 ADD A,#1
;	 DA A ;十进制调整
;	 MOV SEC,A
;	 
;	 CJNE A,#60H,CLKE111 ;秒溢出
;	 MOV SEC,#0
;	 MOV A,MINUTE
;	 ADD A,#1
;	 DA A
;	 MOV MINUTE,A
;	 
;	 CLK0:
;	 CJNE A,#60H,CLKE111  ;分溢出
;	 MOV MINUTE,#0
;	 MOV A,HOUR
;	 ADD A,#1
;	 DA A
;	 MOV HOUR,A
;	 
;	 CJNE A,#24H,CLKE111  ;时溢出
;	 MOV HOUR,#0
;	 MOV A,DAY
;	 ADD A,#1
;	 DA A
;	 MOV DAY,A
;	 MOV A,MONTH    ;查询本月最大日期
;	 INC A
;	 MOVC A,@A+PC
;	 SJMP CLK1
;	 DB 31H,28H,31H       ;对应月份编码:01H,02H,03H
;	 DB 30H,31H,30H       ;对应月份编码:04H,05H,06H
;	 DB 31H,31H,30H       ;对应月份编码:07H,08H,09H
;	 DB 00H,00H,00H       ;对应无效月份编码:0AH,0BH,0CH\n
;	 DB 00H,00H,00H       ;对应无效月份编码:0DH,0EH,0FH\n
;	 DB 31H,30H,31H       ;对应月份编码:10H,11H,12H
;	 
;	 CLK1:
;	 CLR   C
;	 SUBB  A,DAY
;	 JNC   CLKE111                ;本月未满
;	 MOV   A,MONTH
;	 CJNE  A,#2,CLK3       ;是否二月
;	 MOV   A,YEARL
;	 ANL   A,#13H           ;保留年份中非4的整数部分
;	 JNB   ACC.4,CLK2
;	 ADD   A,#2
;	 CLK2:
;	 ANL   A,#3             ;能否被4整除
;	 JNZ   CLK3             ;非闰年
;	 MOV   A,DAY
;	 XRL   A,#29H
;	 JZ    CLKE111              ;闰年二月可以有29日
;	 CLK3:
;	 MOV   DAY,#1          ;调整到下个月的1日
;	 MOV   A,MONTH
;	 ADD   A,#1
;	 DA    A
;	 MOV   MONTH,A
;	 CJNE  A,#13H,CLKE111
;	 MOV   MONTH,#1        ;调整到下一年的一月份
;	 MOV   A,YEARL             ;调整年份
;	 ADD   A,#1
;	 DA    A
;	 MOV   YEARL,A
;	 
;	 CLKE111:
;	 POP 07H
;	 POP 06H
;	 POP 05H
;	 POP 00H
;	 POP PSW
;	 POP ACC
;	 RETI
	 
SHOW:
     MOV A,TIME_ADJUST_MODE
     CJNE A,#0,SHOW2    ;0跳转
     MOV R0,#YEARH ;传地址        模式1的显示
	 INC R0
	 MOV LCD_DATA,#0X80
	 CALL LCD_WRITE_CMD
	 CALL DISPLAY
	 CALL DISPLAY
	 MOV LCD_DATA,#45
	 CALL LCD_WRITE_DATA
	 CALL DISPLAY
	 MOV LCD_DATA,#45
	 CALL LCD_WRITE_DATA
	 CALL DISPLAY
	 
	 PUSH DPH
	 PUSH DPL
	 MOV DPTR,#SITE_WEEK
     CLR A
	 MOV A,TIME_WEEK
	 MOV B,#3
	 MUL AB
	 ADD A, DPL            ; 加上偏移量
     MOV DPL, A
     MOV A, B
     ADDC A, DPH
     MOV DPH, A
	 CLR A
	 MOVC A, @A+DPTR      ; 读取第一个字符
	 MOV LCD_DATA,#0X8C
	 CALL LCD_WRITE_CMD
	 MOV LCD_DATA,A
	 CALL LCD_WRITE_DATA
	 CLR A
	 INC DPTR
	 MOVC A, @A+DPTR      
	 MOV LCD_DATA,A
	 CALL LCD_WRITE_DATA
	 CLR A
	 INC DPTR
	 MOVC A, @A+DPTR      
	 MOV LCD_DATA,A
	 CALL LCD_WRITE_DATA
	 MOV LCD_DATA,#45
	 CALL LCD_WRITE_DATA
	 POP DPL
	 POP DPH
	 
	 MOV LCD_DATA,#0XC2
	 CALL LCD_WRITE_CMD
	 CALL DISPLAY
	 MOV LCD_DATA,#45
	 CALL LCD_WRITE_DATA
	 CALL DISPLAY
	 MOV LCD_DATA,#45
	 CALL LCD_WRITE_DATA
	 CALL DISPLAY
	 SJMP SHOW_END
	 
	 SHOW2:   
     CJNE A,#1,SHOW3
     MOV A,UPRIGHT_TIME_FLAG
     CJNE A,#0,SHOW4	 
	 MOV R0,#TIME_H ;传地址   模式2的显示
	 INC R0
	 MOV LCD_DATA,#0XC2
	 CALL LCD_WRITE_CMD
	 CALL DISPLAY
	 MOV LCD_DATA,#45
	 CALL LCD_WRITE_DATA
	 CALL DISPLAY
	 SJMP SHOW_END
	 
	 SHOW4:      // 模式2的记录数据显示
	 DEC A
     ADD A,ACC
	 ADD A,#TIME_H_1
	 MOV R0,A;传地址
	 INC R0
	 MOV LCD_DATA,#0XC2
	 CALL LCD_WRITE_CMD
	 CALL DISPLAY
	 MOV LCD_DATA,#45
	 CALL LCD_WRITE_DATA
	 CALL DISPLAY
	 
     MOV LCD_DATA,#0XC9
	 CALL LCD_WRITE_CMD
	 MOV A,UPRIGHT_TIME_FLAG
	 ADD A,#30H
	 MOV LCD_DATA,A
	 CALL LCD_WRITE_DATA

     
	 SJMP SHOW_END
	 
	 SHOW3:      //模式3的显示
	 MOV R0,#FALL_TIME_H ;传地址
	 INC R0
	 MOV LCD_DATA,#0XC2
	 CALL LCD_WRITE_CMD
	 CALL DISPLAY
	 MOV LCD_DATA,#45
	 CALL LCD_WRITE_DATA
	 CALL DISPLAY
	 
	 SHOW_END:
	 RET
     DISPLAY: ;对数字进行显示
	 DEC R0
     MOV A,@R0
	 MOV B,#10H
	 DIV AB
	 ADD A,#30H
	 MOV LCD_DATA,A
	 CALL LCD_WRITE_DATA
	 MOV A,B
	 ADD A,#30H
	 MOV LCD_DATA,A
	 CALL LCD_WRITE_DATA
	 RET

LCD_CHECK_BUSY:
	CLR LCD_RS
	SETB LCD_RW
    READ_BUSY:
	SETB LCD_E
	MOV C,LCD_DATA.7
	CLR LCD_E
	JC READ_BUSY
	RET

LCD_WRITE_CMD:   //LCD指令
    CALL LCD_CHECK_BUSY
	CLR LCD_RS
	CLR LCD_RW
	
	CLR LCD_E
;	MOV LCD_DATA,R1
	CALL DELAY_1MS
	SETB LCD_E
	CALL DELAY_1MS
	CLR LCD_E
	RET

LCD_INIT:  
    MOV LCD_DATA,#0X01
	CALL LCD_WRITE_CMD
	MOV LCD_DATA,#0X06
	CALL LCD_WRITE_CMD
	MOV LCD_DATA,#0X0C
	CALL LCD_WRITE_CMD
	MOV LCD_DATA,#0X38
	CALL LCD_WRITE_CMD
	MOV LCD_DATA,#0X80
	CALL LCD_WRITE_CMD
	RET

LCD_WRITE_DATA:   //LCD传输数据
    CALL LCD_CHECK_BUSY
	SETB LCD_RS
	CLR LCD_RW
	
	CLR LCD_E
;	MOV LCD_DATA,A
	CALL DELAY_1MS
	SETB LCD_E
	CALL DELAY_1MS
	CLR LCD_E
	RET

WEEK:       ;蔡勒公式计算星期
    MOV A,YEARL
    MOV B,#16
    DIV AB
    MOV TEMP_BYTE1,B
    MOV B,#10
    MUL AB
    ADD A,TEMP_BYTE1
    MOV TEMP_BYTE1,A ;TEMP_BYTE1=年
	MOV A,YEARH
    MOV B,#16
    DIV AB
    MOV TEMP_BYTE2,B
    MOV B,#10
    MUL AB
    ADD A,TEMP_BYTE2
    MOV TEMP_BYTE2,A ;TEMP_BYTE2=世纪
	
	MOV A,MONTH
    MOV B,#16
    DIV AB
    MOV TEMP_BYTE3,B
    MOV B,#10
    MUL AB
    ADD A,TEMP_BYTE3
    MOV TEMP_BYTE3,A ;TEMP_BYTE3=月
	
    MOV A,DAY
    MOV B,#16
    DIV AB
    MOV TEMP_BYTE4,B
    MOV B,#10
    MUL AB
    ADD A,TEMP_BYTE4
    MOV TEMP_BYTE4,A ;TEMP_BYTE4=日
    
	;;修正
	MOV A, TEMP_BYTE3      ; 月份
    CJNE A, #1, CHECK_FEB
    ; 1月处理
    MOV TEMP_BYTE3, #13   ; month = 13
    ; 年份减1
    MOV A, TEMP_BYTE1
    JZ  YEARL_ZERO1       ; 如果年后两位=0
    DEC TEMP_BYTE1
    SJMP GETW06
	YEARL_ZERO1:
    MOV TEMP_BYTE1, #99   ; 年后两位=99
    DEC TEMP_BYTE2        ; 世纪减1
    SJMP GETW06
    
    CHECK_FEB:
    CJNE A, #2, GETW06    ; 如果不是2月，直接跳转
    ; 2月处理
    MOV TEMP_BYTE3, #14   ; month = 14
    ; 年份减1
    MOV A, TEMP_BYTE1
    JZ  YEARL_ZERO2       ; 如果年后两位=0
    DEC TEMP_BYTE1
    SJMP GETW06
    
    YEARL_ZERO2:
    MOV TEMP_BYTE1,#99   ; 年后两位=99
    DEC TEMP_BYTE2        ; 世纪减1
    ; SJMP GETW06 继续执行

    ; ============ 第三部分：计算蔡勒公式 ============
    GETW06:
    ; 1. 计算 ?(13m-1)/5?
    MOV A, TEMP_BYTE3    ; m
    INC A                ; m+1   ← 关键修正
    MOV B, #13
    MUL AB               ; A = 13(m+1)
    MOV B, #5
    DIV AB               ; A = ?13(m+1)/5?
    MOV TIME_WEEK_1, A            ; R1 = ?13(m+1)/5?
    
    ; 2. 计算 y + ?y/4?
    MOV A, TEMP_BYTE1    ; y
    MOV TIME_WEEK_2, A            ; R2 = y
    MOV B, #4
    DIV AB               ; A = ?y/4?
    ADD A, TIME_WEEK_2            ; A = y + ?y/4?
    MOV TIME_WEEK_3, A            ; R3 = y + ?y/4?
    
    ; 3. 计算 ?c/4? - 2c
    MOV A, TEMP_BYTE2    ; c
    MOV B, #4
    DIV AB               ; A = ?c/4?
    MOV TIME_WEEK_4, A            ; R4 = ?c/4?
    
    MOV A, TEMP_BYTE2    ; c
    ADD A, ACC           ; A = 2c (A×2)
    CPL A                ; 取反
    INC A                ; 加1 = -2c
    ADD A, TIME_WEEK_4            ; A = ?c/4? - 2c
    MOV TIME_WEEK_5, A            ; R5 = ?c/4? - 2c
    
    ; 4. 总和计算
    MOV A, TEMP_BYTE4    ; d
    ADD A, TIME_WEEK_1            ; + ?13(m+1)/5?
    ADD A, TIME_WEEK_3            ; + (y + ?y/4?)
    ADD A, TIME_WEEK_5            ; + (?c/4? - 2c)
    
    ; 5. 处理负数（蔡勒公式结果可能为负）
    JNB ACC.7, POSITIVE  ; 如果最高位为0，是正数
    NEGATIVE:
    ADD A, #7            ; 负数加7
    JB ACC.7, NEGATIVE   ; 如果还是负数，继续加
    POSITIVE:
    
    ; 6. 取模7
    MOV B, #7
    DIV AB               ; B = w mod 7
    
    ; 7. 结果调整（蔡勒公式：0=周六，1=周日...6=周五）
    ; 我们要调整为：0=周日，1=周一...6=周六
    MOV A, B
    CJNE A, #0, NOT_SAT
    ; w=0（周六）→ 调整为6
    MOV A, #6
    SJMP STORE_RESULT
    
    NOT_SAT:
    DEC A                ; w-1：1→0（周日），2→1（周一）...
    
    STORE_RESULT:
    MOV TIME_WEEK, A
    
    RET
;    GET_CORRECT:
;    MOVC A,@A+PCRET
;    DB 0,3,3,6,1,4,6,2,5,0,3,5
	
DELAY_1MS:
    MOV R7, #2      ; 1个机器周期
LOOP1:
    MOV R6, #1    ; 1个机器周期
LOOP2:
    MOV R5, #249    ; 1个机器周期
LOOP3:
    DJNZ R5, LOOP3  ; 2个机器周期
    DJNZ R6, LOOP2  ; 2个机器周期
    DJNZ R7, LOOP1  ; 2个机器周期
    RET             ; 2个机器周期
SITE_DATA:
    DB  0XC9,0XC6,0XC3,0X89,0X86,0X83,0X82,0X81,0X80
SITE_WEEK:		
	DB  53H,55H,4EH
	DB  4DH,4FH,4EH
	DB  54H,55H,45H
	DB  57H,45H,44H
	DB  54H,48H,55H
	DB  46H,52H,49H
	DB  53H,41h,54h

END
