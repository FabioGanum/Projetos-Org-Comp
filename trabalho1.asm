.data
texto_menu: .asciz "1 – Adicionar vagão no início \n2 – Adicionar vagão no final \n3 – Remover vagão por ID \n4 – Listar trem \n5 – Buscar vagão \n6 – Sair\n"
pergunta_id: .asciz "Digite o ID do novo vagão:\n"
pergunta_tipo: .asciz "Digite o tipo do novo vagão:\n"
pergunta_id_excl: .asciz "Digite o ID do vagao a ser excluido:\n"
lista_1: .asciz "O vagao de ID: "
lista_2: .asciz ", do tipo: "
quebra: .asciz "\n"
existe: .asciz "Esse vagao existe!\n"
nao_existe: .asciz "Esse vagao nao existe :( \n"
busca: .asciz "Digite o ID do vagão a ser buscado:\n"
.align 2
cabeca: .word 0	#inicializa a cabeca da lista ocmo 0 (vazia)
.text
.global main                          #entrada do codigo

main:
	#criando o primeiro no, a locomotiva
	#fizemos a escolha de ter uma cabeca sem valor, apontando para a locomotiva, o primeiro vagao fixo, que pode ter valor
	li a7, 9	#carrga 9 para a7 (instrucao de dar memoria)
	li a0, 12	#8bytes serao requisitados (4 para int e 4 para proximo elemento)
	ecall
	mv t0, a0	#move a0 para t0
	li t1, 0	#coloca 0 em t1, 0 é o valor da locomotiva
	sw t1, 0(t0)	#guardamar t1 nos 4 primeiros bytes do novo no
	sw zero, 4(t0)	#inicializamos como zero o endereco do proximo no
	sw zero, 8(t0)	#inicializa como zero o ID da locomotiva
	la t1, cabeca	#endereco de cabeca em t1
	sw t0, 0(t1)	#guarda o endereco do primeiro no nos 4 ultimos bytes de cabeca

menu: 
	li a7, 4	#carrega a instrucao 4 (printar string) no a7
	la a0, texto_menu	#carrega o endereco do menu em a0
	ecall		#verifica o que executar em a7. procura o endereco do objeto da execucao em a0
	
	li a7, 5	#le inteiro do teclado
	ecall
	mv t0, a0	#coloca a0 no t0 (ou seja, a opcao agora esta em t0)
	
	#COMPARACOES:

	li t1, 1	#carrega 1 no t1, que sera comparado
	beq t0, t1, chama_addin	#compara to e t1. Se iguais, vai para chama_add

	li t1, 2	#carrega 2 no t1, que sera comparado
	beq t0, t1, chama_addfim	#compara to e t1. Se iguais, vai para chama_add
	
	li t1, 3	#carrega 3 no t1, que sera comparado
	beq t0, t1, chama_remId	#compara to e t1. Se iguais, vai para chama_add
	
	li t1, 4	#carrega 4 no t1, que sera comparado
	beq t0, t1, chama_listar	#compara to e t1. Se iguais, vai para chama_add
	
	li t1, 5	#carrega 5 no t1, que sera comparado
	beq t0, t1, chama_buscaVag	#compara to e t1. Se iguais, vai para chama_add
	
	li t1, 6	#carrega 6 no t1, que sera comparado
	beq t0, t1, sair	#compara to e t1. Se iguais, vai para chama_add

	#TRAMPOLINS (mesma logica do primeiro comentario para todas as labels)
chama_addin: 
	jal adicionar_vagao_inicio	#pula para adicionar vagao e deixa o retorno em ra
	j menu			#pula para o menu

chama_addfim:
	jal adicionar_vagao_fim
	j menu
	
chama_remId:
	jal remover_id
	j menu
	
chama_listar:
	jal listar_vagao
	j menu
	
chama_buscaVag:
	jal buscar_vagao
	j menu

	#FUBNCOES
adicionar_vagao_inicio:
	li a7, 9	#crianddo o novo vagao
	li a0, 12
	ecall
	mv t0, a0	#passando o endereco do vagao novo para a0
	la t1, cabeca	#t1 tem o endereco da cabeca
	lw t1, 0(t1)	#t1 tem o endereco da locomotivas
	lw t2, 4(t1)	#t2 tem o endereco do segundo no
	sw zero, 0(t0)	#inicializa como 0 o valor do novo vagao
	sw zero, 8(t0)	#inicializa como 0 o ID do novo vagao
	sw t2, 4(t0)	#escreve o endereco do antigo segundo vagao no novo vagao
	sw t0, 4(t1)	#escreve o endereco do novo vagao na locomotiva
	
	li a7, 4		#pergunta o novo id
	la a0, pergunta_id
	ecall
	li a7, 5		#le o numero
	ecall
	sw a0, 8(t0)		#escreve o id do vagao
	
	
	li a7, 4
	la a0, pergunta_tipo	#pergunta o tipo do vagao
	ecall
	li a7, 5		#le o numero
	ecall
	sw a0, 0(t0)		#escreve o tipo do vagao
	
	ret	#retorna da funcao
	
adicionar_vagao_fim:
	li a7, 9	#criando o novo vagao
	li a0, 12
	ecall
	mv t0, a0	#endereco do novo vagao em t0
	
	li t1, 	0	#escreve zero em t1
	la t2, cabeca	#t2 tem endereco da cabeca
	lw t3, 0(t2)
	beq t1, t3, ins_cabeca
	lw t2, 4(t3)
loop:	beq t1, t2, ins_fim
	mv t3, t2
	lw t2, 4(t2)
	j loop
volta:	li a7, 4		#pergunta o novo id
	la a0, pergunta_id
	ecall
	li a7, 5		#le o numero
	ecall
	sw a0, 8(t0)		#escreve o id do vagao	
	li a7, 4
	la a0, pergunta_tipo	#pergunta o tipo do vagao
	ecall
	li a7, 5		#le o numero
	ecall
	sw a0, 0(t0)		#escreve o tipo do vagao
	
	ret	#retorno
ins_cabeca:
	sw t0, 0(t3)
	j volta
ins_fim:
	sw t0, 4(t3)
	j volta
	
remover_id:
	li a7, 4		#pergunta o id do vagao a ser excluido
	la a0, pergunta_id_excl
	ecall
	li a7, 5		#leitura da resposta
	ecall
	mv t0, a0		#o id esta em t0
	la t1, cabeca
	lw t2, 0(t1)	#t2 aponta para locomotiva
loop2:	lw t1, 4(t2)	#t1 aponta para o segundo vagao, ja que a locomotiva nao pode ser apagada
	lw t3, 8(t1)	#t3 tem o ID de t1
	beq t3, t0, excluir
	mv t2, t1
	j loop2
volta2: ret	#retorno
excluir: 
	lw t4, 4(t1)	#t4 tem o vagao depois de t1
	mv t4, t2	#escreve o endereco do proximo vagao no anterior
	j volta2
	
listar_vagao:		#FALTA A FORMATACAO
	la t0, cabeca
	lw t0, 0(t0)	#achando a locomotiva
	lw t1, 4(t0)	#t1 é sempre o vagao atual
	li t0, 0	#t0 é o controle de 0
print:	li a7, 4	#inicio do print
	la a0, lista_1
	ecall
	li a7, 1
	lw a0, 8(t1)
	ecall
	li a7, 4
	la a0, lista_2
	ecall
	li a7, 1
	lw a0, 0(t1)
	ecall				#fim do print
	lw t2, 4(t1)			#l2 tem o endereco do proximo vagao
	beq t2, t0, fim_do_trem		#verifica se há proximo vagao
	mv t1, t2			#t2 -> t1, e reinicia o processo
	j print
fim_do_trem:	ret

buscar_vagao:
	li a7, 4	#imprime mensagem
	la a0, busca
	ecall
	li a7, 5	#le o id
	ecall
	mv t0, a0	#guarda o id a ser buscado em t0
	li t4, 0	#t4 sera o 0
	la t1, cabeca
	lw t2, 0(t1)	#como esse t2 é a locomotiva, com id fixo 0, pula para proxima
	lw t2, 4(t2)
verifica_dnv:	beq t2, t4, nao_achou	#verifica se há proximo vagao
	lw t3, 8(t2)
	beq t3, t0, achou	#verifica se os IDs são iguais
	lw t2, 4(t2)
	j verifica_dnv
achou: 	li a7, 4		#printa a resposta
	la a0, existe
	ecall
	j fim_procura
nao_achou: li a7, 4		#printa a resposta
	la a0, nao_existe
	ecall
	j fim_procura
fim_procura:	ret		#fim da funcao

sair:
	li a7, 10	#codigo de fim do programa
	ecall


	#FALTA:
#formatacao
#tratamento de entradas erradas
#tratar lista vazia
