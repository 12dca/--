
FALL_TIME_L DATA 51H       ;����ʱ��ʱ��8λ
FALL_TIME_H DATA 52H       ;����ʱ��ʱ��8λ
TIME_L DATA 53H       ;��ʱ��8λ
TIME_H DATA 54H       ;��ʱ��8λ
TIME_WEEK DATA 56H       ;���ڴ�ŵ�Ԫ
TIME_WEEK_1 DATA 5CH ;��ݵ���λ��ŵ�Ԫ(BCD��)
TIME_WEEK_2 DATA 5DH ;��ݵ���λ��ŵ�Ԫ(BCD��)
TIME_WEEK_3 DATA 5EH ;�·ݴ�ŵ�Ԫ(BCD��)
TIME_WEEK_4 DATA 5FH ;�մ�ŵ�Ԫ(BCD��)
TIME_WEEK_5 DATA 55H ;�մ�ŵ�Ԫ(BCD��)

TEMP_BYTE1 DATA 57H
TEMP_BYTE2 DATA 58H
TEMP_BYTE3 DATA 59H
TEMP_BYTE4 DATA 5AH
UPRIGHT_TIME_FLAG DATA 5BH    //����ʱ��־λ
TIME_ADJUST_MODE DATA 50H     //ģʽѡ��
TIME_FALL_FLAG BIT 20H.1      //����ʱ��־λ
UPRIGHT_TIME_NUMBER DATA 3FH  //����ʱ���ʱ���¼������
TIME_H_3 DATA 3EH             //3������ʱ�ڵ��¼
TIME_L_3 DATA 3DH 	
TIME_H_2 DATA 3CH       
TIME_L_2 DATA 3BH 
TIME_H_1 DATA 3AH       
TIME_L_1 DATA 39H       
TIME_ADJUST_FLAG DATA 38H    //��˸��־   
TIME_DELAY_FLAG DATA 37H
YEARH DATA 36H ;��ݸ���λ
YEARL DATA 35H ;��ݵ���λ��ŵ�Ԫ(BCD��)
MONTH DATA 34H ;�·ݴ�ŵ�Ԫ(BCD��)
DAY DATA 33H ;�մ�ŵ�Ԫ(BCD��)
HOUR DATA 32H ;ʱ��ŵ�Ԫ(BCD��)
MINUTE DATA 31H ;�ִ�ŵ�Ԫ(BCD��)
SEC DATA 30H ;���ŵ�Ԫ(BCD��)
TIMES DATA 21H
; DS1302���Ŷ���
RST    BIT P1.2      ; ��λ����
SCLK   BIT P1.7      ; ����ʱ��
IO     BIT P2.7      ; ������

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
MODE_NUMBER SET 3
READ_SEC   EQU 0x81   ; ����
READ_MIN   EQU 0x83   ; ����
READ_HOUR  EQU 0x85   ; ��ʱ
READ_DAY   EQU 0x87   ; ����
READ_MONTH EQU 0x89   ; ����
READ_WEEK  EQU 0x8B   ; ������
READ_YEAR  EQU 0x8D   ; ����
;bz1 BIT 21H.0
;time_adjust_flag BIT 20H
ORG 0000H          ;����ִ�п�ʼ��ַ\n
LJMP  START  ;�������STARTִ��\n
ORG 0030H 
;ORG 0003H          ;���ж�0�жϳ������\n
;RETI                     ;���ж�0�жϷ���\n
ORG 000BH        ;��ʱ��T0�жϳ���\n
;LJMP  INTT0  ;����INTTOִ��\n
;ORG 0013H        ;���ж�1�жϳ������\n
;RETI                   ;���ж�1�жϷ���\n
ORG 001BH        ;��ʱ��T1�жϳ������\n
LJMP  INTT1  ;����INTTOִ��\n
;RETI
;ORG 0023H        ;�����жϳ�����ڵ�ַ
;RETI                    ;�����жϳ��򷵻�\n
START:               ;�� �� ��  
     
     MOV R0,#30H
     MOV R7,#16
     CLEETE:
     MOV @R0,#00H
     INC R0
     DJNZ R7,CLEETE
	 MOV SP,#60H
	 MOV TIME_ADJUST_FLAG,#0
	 MOV TIME_ADJUST_MODE,#0
	 SETB TIME_FALL_FLAG
;     MOV TIMES,#00H ;���ʱ��־
     MOV TMOD,#11H ;��T0Ϊ16λ��ʱ��    ��ʱ�ã�
     MOV TH0,#63H ;40MS��ʱ��ֵ
     MOV TL0,#0C0H ;40MS��ʱ��ֵ��T0
	 MOV TH1, #0D8H       ; ��λ
     MOV TL1, #0F0H       ; ��λ
	 
	  ; ��ʼ��IO��: ��IO��Ϊ����(��1)
     SETB    IO
     CLR     SCLK
     CLR     RST
	 SETB EA    ;�������ж�
;	 SETB ET0    ;������ʱ���ж�
	 SETB ET1    ;������ʱ���ж�
;	 SETB TR0    ;������ʱ��
	 SETB PT1    ; ��ʱ��1�����ȼ�
	 MOV R4,#19H
	 CALL LCD_INIT
	 MOV DPTR,#SITE_DATA  //���õ�����ַ
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
	 MOV     HOUR, A              ; �浽ʱ����
	 MOV     R7, #84H
	 MOV     A, HOUR       ; ���¼���Сʱֵ
     ANL     A, #7FH       ; �������λ����8λ����������7λ
     MOV     R6, A         ; ���洦�����ֵ��R6
     LCALL   DS1302_WRITE
	 LCALL   DS1302_Disable_Write         ; ����д����
	 MAIN:
	 MOV A,TIME_ADJUST_FLAG
     CJNE A,#0,main1
	 CALL GET_TIME
	 SJMP main2
	 main1:
	 LCALL WRITE_ALL_TIME
	 main2:
	 CALL WEEK   //�������
	 CALL SHOW   //��ʾ
	 CALL KEY_SCAN  //�����߼�����
	 LJMP  MAIN
	 
GET_TIME:
    MOV     R7, #81H
    LCALL   DS1302_READ
	MOV     SEC, A              ; �浽�����
	MOV     R7, #83H
    LCALL   DS1302_READ
	MOV     MINUTE, A              ; �浽�ֱ���
	MOV     R7, #85H
    LCALL   DS1302_READ
	MOV     HOUR, A              ; �浽ʱ����
	MOV     R7, #87H
    LCALL   DS1302_READ
	MOV     MONTH, A              ; �浽�±���
	MOV     R7, #8DH
    LCALL   DS1302_READ
	MOV     YEARL, A              ; �浽�����
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
	 MOV     R7, #86H
     MOV     R6, MONTH         
     LCALL   DS1302_WRITE
	 MOV     R7, #8CH
     MOV     R6, YEARL         
     LCALL   DS1302_WRITE
	 LCALL   DS1302_Disable_Write         ; ����д����
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
; BCD ��תʮ���� (������) �ӳ���
; ���: A = BCD �� (�� 0x35)
; ����: A = ʮ������ֵ (�� 35)
; ԭ��: ʮλ*10 + ��λ
;--------------------------------------------------------------------
BCD_TO_DEC:
    PUSH    B
    MOV     B, A
    ANL     A, #0FH         ; ��λ
    MOV     R2, A
    MOV     A, B
    SWAP    A
    ANL     A, #0FH         ; ʮλ
    MOV     B, #10
    MUL     AB
    ADD     A, R2
    POP     B
    RET
;------------------------------------------------------
; ��DS1302ָ�������ַ��һ���ֽ� (������A��)
; ����������A��
;------------------------------------------------------
DS1302_READ:
    CLR     RST
    CLR     SCLK
    SETB    RST
    MOV     A, R7           ; ���͵�ַ
    LCALL   DS1302_WRITE_BYTE
    SETB    IO              ; �л� IO Ϊ���루51 ������ǰ��д 1��
    LCALL   DS1302_READ_BYTE
    CLR     SCLK
    CLR     RST
    RET

; �� DS1302 ָ����ַ��ȡһ�������ֽ�
; ��ڣ�R7 = �����ַ���� 0x81 ���룩
; ���ڣ�A = ����������
;------------------------------------------------
DS1302_WRITE:
    CLR     RST
    CLR     SCLK
    SETB    RST
    MOV     A, R7           ; ���͵�ַ
    LCALL   DS1302_WRITE_BYTE
    MOV     A, R6           ; ��������
    LCALL   DS1302_WRITE_BYTE
    CLR     SCLK
    CLR     RST
    RET
; �� DS1302 д��һ���ֽڣ���λ�ȣ�
DS1302_WRITE_BYTE:
    PUSH    ACC
    MOV     R7, #8          ; 8 λ����
WB_LOOP:
    CLR     SCLK            ; ʱ������
    RRC     A               ; ��λ���� CY
    MOV     IO, C           ; �������λ
    SETB    SCLK            ; ʱ�������أ�DS1302 ����
    DJNZ    R7, WB_LOOP
    POP     ACC
    RET
//��DS1302��ȡһ���ֽ� (����������A��)	 
DS1302_READ_BYTE:
    PUSH  B
    MOV   R6, #8
    MOV   B, #0
RB_LOOP:
    SETB  SCLK             ; ����ʱ�ӣ�׼��
    NOP
	NOP
    CLR   SCLK             ; �� �½���: DS1302�ڴ˿̸ı�IO��������
	NOP
    NOP
    MOV   C, IO            ; ������ȡ�ȶ�������
    MOV   A, B
    RRC   A                ; �������λ����ACC�ĵ�λ
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
	 PUSH 0F0H       ; ����B
	 MOV TH1, #0D8H       ; ��λ
     MOV TL1, #0F0H       ; ��λ
	 
	 MOV A,TIME_ADJUST_MODE   //��ȡģʽ
     CJNE A,#1,ZD22;   
	 
	 MOV A,TIME_L  //����ʱ
	 ADD A,#1
	 MOV B,A
	 DA A ;ʮ���Ƶ���
	 MOV TIME_L,A
	 MOV A,B
	 
	 CJNE A,#9AH,ZD11 ;
	 MOV TIME_L,#0
	 MOV A,TIME_H
	 ADD A,#1
	 DA A
	 MOV TIME_H,A
	 SJMP ZD11
	 
	 ZD22:    //����ʱ
	 MOV A,FALL_TIME_L
	 ADD A, #99H       ; �൱�ڼ�1
	 DA A ;ʮ���Ƶ���
	 MOV FALL_TIME_L,A
	 JNC ZD33 ;
	 SJMP ZD44
	 ZD33:
	 MOV A,FALL_TIME_H
	 ADD A, #99H       ; �൱�ڼ�1
	 DA A
	 MOV FALL_TIME_H,A
	 SJMP ZD44
	 
	 ZD44:
	 MOV R5,FALL_TIME_L
	 MOV R6,FALL_TIME_H
	 CJNE R6,#00H,ZD11
	 CJNE R5,#00H,ZD11
	 CLR TR1           //�رն�ʱ������������
	 CLR BUZZER
	 SJMP ZD11
     ZD11:
	 POP 0F0H       ; ��B
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
	 JNZ KEY1    //TIME_DELAY_FLAG������0��ת
	 WUYU:       //��˸
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
     MOV   C, TIME_ADJUST      ; ��ȡ����״̬
     JC    KEY2       ; ���C=1������δ���£�����ת
     MOV R0,#20
	 DELAY_S0:
	 CALL DELAY_1MS
     DJNZ R0,DELAY_S0
     MOV   C, TIME_ADJUST      ; �ٴμ��
     JC    KEY2       ; ����Ƕ�������ת
	 KEY_WAIT_RELEASE0:
	 
     MOV   C, TIME_ADJUST
     JNC   KEY_WAIT_RELEASE0    ; ������ǵ͵�ƽ�������ȴ�
	 
     MOV A,TIME_ADJUST_MODE
     CJNE A,#0,KEY1_1;
	 MOV DPTR,#SITE_DATA     //ģʽ1
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
	 MOV TIME_L,#0         //����ʱ����
	 MOV TIME_H,#0
;	 MOV UPRIGHT_TIME_NUMBER,#0
	 SJMP KEY2
;	 INC YEARL
     KEY1_2:
	 MOV DPTR,#SITE_DATA  //����ʱѡ��λ�ý��е���
	 INC DPTR
;	 CPL TIME_ADJUST_FLAG2
     INC TIME_ADJUST_FLAG
     MOV B,#2
	 MOV A,TIME_ADJUST_FLAG
	 DIV AB
	 MOV TIME_ADJUST_FLAG,B
	 SJMP KEY2
	 
	 KEY2:
     MOV   C, ADD_ONE      ; ��ȡ����״̬
     JC    KEY3       ; ���C=1������δ���£�����ת
     MOV R0,#20       
	 DELAY_S1:
	 CALL DELAY_1MS
     DJNZ R0,DELAY_S1
     MOV   C, ADD_ONE      ; �ٴμ��
     JC    KEY3       ; ����Ƕ�������ת
	 KEY_WAIT_RELEASE1:
     MOV   C, ADD_ONE
     JNC   KEY_WAIT_RELEASE1    ; ������ǵ͵�ƽ�������ȴ�
;	 JNB TIME_ADJUST_FLAG,KEY_END
     MOV A,TIME_ADJUST_FLAG  //
     CJNE A,#1,KEY2_2  
	 MOV A,TIME_ADJUST_MODE
	 CJNE A,#0,KEY2_1
	 CALL INC_ONE      //ģʽ1��1
	 SJMP KEY3
	 KEY2_1:           //ģʽ3��1
	 CALL FALL_INC_ONE
	 SJMP KEY3
	 KEY2_2:   //ģʽ2�Ķ�μ�ʱ��¼
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
	 MOV   C, DEC_ONE      ; ��ȡ����״̬
     JC    KEY4       ; ���C=1������δ���£�����ת
     MOV R0,#20
	 DELAY_S2:
	 CALL DELAY_1MS
     MOV   C, DEC_ONE      ; �ٴμ��
     DJNZ R0,DELAY_S2
     JC    KEY4       ; ����Ƕ�������ת
	 KEY_WAIT_RELEASE2:
     MOV   C, DEC_ONE
     JNC   KEY_WAIT_RELEASE2    ; ������ǵ͵�ƽ�������ȴ�
	 JNB BUZZER,KEY3_1 ;BUZZER=0��ת
	 CPL TR1    //��ͣ
	 SJMP KEY4
	 KEY3_1:    //����ʱ�����ָ�
	 SETB BUZZER
	 MOV FALL_TIME_L,R3
	 MOV FALL_TIME_H,R2
	 SJMP KEY4
	 
	 KEY4:
	 MOV   C, ADD_SITE      ; ��ȡ����״̬
     JC    KEY5       ; ���C=1������δ���£�����ת
     MOV R0,#20
	 DELAY_S3:
	 CALL DELAY_1MS
     MOV   C, ADD_SITE      ; �ٴμ��
     DJNZ R0,DELAY_S3
     JC    KEY5       ; ����Ƕ�������ת
	 KEY_WAIT_RELEASE3:
     MOV   C, ADD_SITE
     JNC   KEY_WAIT_RELEASE3    ; ������ǵ͵�ƽ�������ȴ�
	 
     MOV A,TIME_ADJUST_MODE
     CJNE A,#0,KEY4_1
	 
	 CLR A    //ģʽ1����˸λ�õ���
	 MOVC A,@A+DPTR
	 CJNE A, #0X80,RETURN_SITE
	 MOV DPTR,#SITE_DATA
	 SJMP KEY_END
	 
	 KEY4_1:  //ģʽ3����˸λ�õ���
	 CJNE A,#2,KEY4_2
	 CLR A
	 MOVC A,@A+DPTR
	 CJNE A, #0XC3,RETURN_SITE
	 MOV DPTR,#SITE_DATA
	 INC DPTR
	 SJMP KEY_END
	 
	 KEY4_2:  //ģʽ2�ļ�¼�������л�
	 MOV LCD_DATA,#0X01
	 CALL LCD_WRITE_CMD 
	 INC UPRIGHT_TIME_FLAG
	 MOV B,#4
	 MOV A,UPRIGHT_TIME_FLAG
	 DIV AB
	 MOV UPRIGHT_TIME_FLAG,B

	 
	 KEY5:
	 MOV   C, SITE_MODE      ; ��ȡ����״̬
     JC    KEY_END       ; ���C=1������δ���£�����ת
     MOV R0,#20
	 DELAY_S4:
	 CALL DELAY_1MS
     MOV   C, SITE_MODE      ; �ٴμ��
     DJNZ R0,DELAY_S4
     JC    KEY_END       ; ����Ƕ�������ת
	 KEY_WAIT_RELEASE4:
     MOV   C, SITE_MODE
     JNC   KEY_WAIT_RELEASE4    ; ������ǵ͵�ƽ�������ȴ�
	 
	 MOV LCD_DATA,#0X01       //ģʽ�л�
	 CALL LCD_WRITE_CMD
	 MOV TIME_ADJUST_FLAG,#0
	 SETB TR0
	 MOV TIME_H,#0
	 MOV TIME_L,#0
	 MOV FALL_TIME_L,R3
	 MOV FALL_TIME_H,R2
	 CLR TR1
	 MOV TH1, #0D8H       ; ��λ
     MOV TL1, #0F0H       ; ��λ
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
	 DA A ;�������
	 MOV FALL_TIME_L,A
	 
	 FALL_INC_ONE11:
	 CJNE A, #0XC3,FALL_INC_ONE_END
	 MOV A,FALL_TIME_H
	 ADD A,#1
	 DA A ;�����
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
	 DA A ;�����
	 MOV SEC,A
	 CJNE A,#60H,INC_ONE888 ;�����
	 MOV SEC,#0
     INC_ONE000:
     CJNE A, #0XC6,INC_ONE001
	 MOV A,MINUTE
	 ADD A,#1
	 DA A ;
	 MOV MINUTE,A
	 INC_ONE888:
	 CJNE A,#60H,INC_ONE_END ;�����
	 MOV MINUTE,#0
	 SJMP INC_ONE_END
	 INC_ONE001:
     CJNE A, #0XC3,INC_ONE002
	 MOV A,HOUR
	 ADD A,#1
	 DA A ;
	 MOV HOUR,A
	 CJNE A,#24H,INC_ONE_END ;ʱ���
	 MOV HOUR,#0
	 SJMP INC_ONE_END
	 INC_ONE002:
     CJNE A, #0X89,INC_ONE003
	 MOV A,DAY
	 ADD A,#1
	 DA A ;
	 MOV DAY,A
	 
	 MOV A,MONTH    ;��ѯ�����������
	 INC A
	 MOVC A,@A+PC
	 SJMP INC_ONE010
	 DB 31H,28H,31H       ;��Ӧ�·ݱ���:01H,02H,03H
	 DB 30H,31H,30H       ;��Ӧ�·ݱ���:04H,05H,06H
	 DB 31H,31H,30H       ;��Ӧ�·ݱ���:07H,08H,09H
	 DB 00H,00H,00H       ;��Ӧ��Ч�·ݱ���:0AH,0BH,0CH\n
	 DB 00H,00H,00H       ;��Ӧ��Ч�·ݱ���:0DH,0EH,0FH\n
	 DB 31H,30H,31H       ;��Ӧ�·ݱ���:10H,11H,12H
	 
	 INC_ONE010:
	 CLR   C
	 SUBB  A,DAY
	 JNC   INC_ONE_END                ;����δ��
	 MOV   A,MONTH
	 CJNE  A,#2,INC_ONE012       ;�Ƕ���
	 MOV   A,YEARL
	 ANL   A,#13H           ;��������з�4����������
	 JNB   ACC.4,INC_ONE011
	 ADD   A,#2
	 INC_ONE011:
	 ANL   A,#3             ;�ܷ�4����
	 JNZ   INC_ONE012             ;������
	 MOV   A,DAY
	 XRL   A,#29H
	 JZ    INC_ONE_END              ;������¿�����29��
	 INC_ONE012:
	 MOV   DAY,#1          ;�������¸��µ�1��	 
	 SJMP INC_ONE_END
	 
	 INC_ONE003:
     CJNE A, #0X86,INC_ONE004
	 MOV A,MONTH
	 ADD A,#1
	 DA A ;
	 MOV MONTH,A
	 CJNE A,#13H,INC_ONE_END ;�����
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
;     MOV TH0,#63H ;����
;	 
;	 DJNZ R4,CLKE111
;	 MOV R4,#19H
;	 MOV A,SEC
;	 ADD A,#1
;	 DA A ;ʮ���Ƶ���
;	 MOV SEC,A
;	 
;	 CJNE A,#60H,CLKE111 ;�����
;	 MOV SEC,#0
;	 MOV A,MINUTE
;	 ADD A,#1
;	 DA A
;	 MOV MINUTE,A
;	 
;	 CLK0:
;	 CJNE A,#60H,CLKE111  ;�����
;	 MOV MINUTE,#0
;	 MOV A,HOUR
;	 ADD A,#1
;	 DA A
;	 MOV HOUR,A
;	 
;	 CJNE A,#24H,CLKE111  ;ʱ���
;	 MOV HOUR,#0
;	 MOV A,DAY
;	 ADD A,#1
;	 DA A
;	 MOV DAY,A
;	 MOV A,MONTH    ;��ѯ�����������
;	 INC A
;	 MOVC A,@A+PC
;	 SJMP CLK1
;	 DB 31H,28H,31H       ;��Ӧ�·ݱ���:01H,02H,03H
;	 DB 30H,31H,30H       ;��Ӧ�·ݱ���:04H,05H,06H
;	 DB 31H,31H,30H       ;��Ӧ�·ݱ���:07H,08H,09H
;	 DB 00H,00H,00H       ;��Ӧ��Ч�·ݱ���:0AH,0BH,0CH\n
;	 DB 00H,00H,00H       ;��Ӧ��Ч�·ݱ���:0DH,0EH,0FH\n
;	 DB 31H,30H,31H       ;��Ӧ�·ݱ���:10H,11H,12H
;	 
;	 CLK1:
;	 CLR   C
;	 SUBB  A,DAY
;	 JNC   CLKE111                ;����δ��
;	 MOV   A,MONTH
;	 CJNE  A,#2,CLK3       ;�Ƕ���
;	 MOV   A,YEARL
;	 ANL   A,#13H           ;��������з�4����������
;	 JNB   ACC.4,CLK2
;	 ADD   A,#2
;	 CLK2:
;	 ANL   A,#3             ;�ܷ�4����
;	 JNZ   CLK3             ;������
;	 MOV   A,DAY
;	 XRL   A,#29H
;	 JZ    CLKE111              ;������¿�����29��
;	 CLK3:
;	 MOV   DAY,#1          ;�������¸��µ�1��
;	 MOV   A,MONTH
;	 ADD   A,#1
;	 DA    A
;	 MOV   MONTH,A
;	 CJNE  A,#13H,CLKE111
;	 MOV   MONTH,#1        ;��������һ���һ�·�
;	 MOV   A,YEARL             ;�������
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
     CJNE A,#0,SHOW2    ;0��ת
     MOV R0,#YEARH ;����ַ        ģʽ1����ʾ
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
	 ADD A, DPL            ; ����ƫ����
     MOV DPL, A
     MOV A, B
     ADDC A, DPH
     MOV DPH, A
	 CLR A
     MOVC A, @A+DPTR      ; ��ȡ��һ���ַ�
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
	 MOV R0,#TIME_H ;����ַ   ģʽ2����ʾ
	 INC R0
	 MOV LCD_DATA,#0XC2
	 CALL LCD_WRITE_CMD
	 CALL DISPLAY
	 MOV LCD_DATA,#45
	 CALL LCD_WRITE_DATA
	 CALL DISPLAY
	 SJMP SHOW_END
	 
	 SHOW4:      // ģʽ2�ļ�¼������ʾ
	 DEC A
     ADD A,ACC
	 ADD A,#TIME_H_1
	 MOV R0,A;����ַ
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
	 
	 SHOW3:      //ģʽ3����ʾ
	 MOV R0,#FALL_TIME_H ;����ַ
	 INC R0
	 MOV LCD_DATA,#0XC2
	 CALL LCD_WRITE_CMD
	 CALL DISPLAY
	 MOV LCD_DATA,#45
	 CALL LCD_WRITE_DATA
	 CALL DISPLAY
	 
	 SHOW_END:
	 RET
     DISPLAY: ;�����ֽ�����ʾ
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

LCD_WRITE_CMD:   //LCDָ��
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

LCD_WRITE_DATA:   //LCD��������
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

WEEK:       ;���չ�ʽ�����������
    MOV A,YEARL
    MOV B,#16
    DIV AB
    MOV TEMP_BYTE1,B
    MOV B,#10
    MUL AB
    ADD A,TEMP_BYTE1
    MOV TEMP_BYTE1,A ;TEMP_BYTE1=��
	MOV A,YEARH
    MOV B,#16
    DIV AB
    MOV TEMP_BYTE2,B
    MOV B,#10
    MUL AB
    ADD A,TEMP_BYTE2
    MOV TEMP_BYTE2,A ;TEMP_BYTE2=����
	
	MOV A,MONTH
    MOV B,#16
    DIV AB
    MOV TEMP_BYTE3,B
    MOV B,#10
    MUL AB
    ADD A,TEMP_BYTE3
    MOV TEMP_BYTE3,A ;TEMP_BYTE3=��
	
    MOV A,DAY
    MOV B,#16
    DIV AB
    MOV TEMP_BYTE4,B
    MOV B,#10
    MUL AB
    ADD A,TEMP_BYTE4
    MOV TEMP_BYTE4,A ;TEMP_BYTE4=��
    
	;;����
	MOV A, TEMP_BYTE3      ; �·�
    CJNE A, #1, CHECK_FEB
    ; 1�´���
    MOV TEMP_BYTE3, #13   ; month = 13
    ; ��ݼ�1
    MOV A, TEMP_BYTE1
    JZ  YEARL_ZERO1       ; ��������λ=0
    DEC TEMP_BYTE1
    SJMP GETW06
	YEARL_ZERO1:
    MOV TEMP_BYTE1, #99   ; �����λ=99
    DEC TEMP_BYTE2        ; ���ͼ�1
    SJMP GETW06
    
    CHECK_FEB:
    CJNE A, #2, GETW06    ; �������2�£�ֱ����ת
    ; 2�´���
    MOV TEMP_BYTE3, #14   ; month = 14
    ; ��ݼ�1
    MOV A, TEMP_BYTE1
    JZ  YEARL_ZERO2       ; ��������λ=0
    DEC TEMP_BYTE1
    SJMP GETW06
    
    YEARL_ZERO2:
    MOV TEMP_BYTE1,#99   ; �����λ=99
    DEC TEMP_BYTE2        ; ���ͼ�1
    ; SJMP GETW06 ����ִ��

    ; ============ �������֣�������չ�ʽ ============
    GETW06:
    ; 1. ���� ?(13m-1)/5?
    MOV A, TEMP_BYTE3    ; m
    INC A                ; m+1   �� �ؼ�����
    MOV B, #13
    MUL AB               ; A = 13(m+1)
    MOV B, #5
    DIV AB               ; A = ?13(m+1)/5?
    MOV TIME_WEEK_1, A            ; R1 = ?13(m+1)/5?
    
    ; 2. ���� y + ?y/4?
    MOV A, TEMP_BYTE1    ; y
    MOV TIME_WEEK_2, A            ; R2 = y
    MOV B, #4
    DIV AB               ; A = ?y/4?
    ADD A, TIME_WEEK_2            ; A = y + ?y/4?
    MOV TIME_WEEK_3, A            ; R3 = y + ?y/4?
    
    ; 3. ���� ?c/4? - 2c
    MOV A, TEMP_BYTE2    ; c
    MOV B, #4
    DIV AB               ; A = ?c/4?
    MOV TIME_WEEK_4, A            ; R4 = ?c/4?
    
    MOV A, TEMP_BYTE2    ; c
    ADD A, ACC           ; A = 2c (A��2)
    CPL A                ; ȡ��
    INC A                ; ��1 = -2c
    ADD A, TIME_WEEK_4            ; A = ?c/4? - 2c
    MOV TIME_WEEK_5, A            ; R5 = ?c/4? - 2c
    
    ; 4. �ܺͼ���
    MOV A, TEMP_BYTE4    ; d
    ADD A, TIME_WEEK_1            ; + ?13(m+1)/5?
    ADD A, TIME_WEEK_3            ; + (y + ?y/4?)
    ADD A, TIME_WEEK_5            ; + (?c/4? - 2c)
    
    ; 5. �������������չ�ʽ�������Ϊ����
    JNB ACC.7, POSITIVE  ; ������λΪ0��������
    NEGATIVE:
    ADD A, #7            ; ������7
    JB ACC.7, NEGATIVE   ; ������Ǹ�����������
    POSITIVE:
    
    ; 6. ȡģ7
    MOV B, #7
    DIV AB               ; B = w mod 7
    
    ; 7. ������������չ�ʽ��0=������1=����...6=���壩
    ; ����Ҫ����Ϊ��0=���գ�1=��һ...6=����
    MOV A, B
    CJNE A, #0, NOT_SAT
    ; w=0���������� ����Ϊ6
    MOV A, #6
    SJMP STORE_RESULT
    
    NOT_SAT:
    DEC A                ; w-1��1��0�����գ���2��1����һ��...
    
    STORE_RESULT:
    MOV TIME_WEEK, A
    
    RET
;    GET_CORRECT:
;    MOVC A,@A+PCRET
;    DB 0,3,3,6,1,4,6,2,5,0,3,5
	
DELAY_1MS:
    MOV R7, #2      ; 1����������
LOOP1:
    MOV R6, #1    ; 1����������
LOOP2:
    MOV R5, #249    ; 1����������
LOOP3:
    DJNZ R5, LOOP3  ; 2����������
    DJNZ R6, LOOP2  ; 2����������
    DJNZ R7, LOOP1  ; 2����������
    RET             ; 2����������
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