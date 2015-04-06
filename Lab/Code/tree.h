#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef _TREE_H_
#define _TREE_H_
#define MAX_LEN_OF_NAME 32+1
#define MAX_COUNT_OF_CHILD 7
typedef struct Node
{
	int type;//类型
	char name[MAX_LEN_OF_NAME];//ID的名称
	int line;//行号
	int value_i;//整形数值
	float value_f;//浮点形数值
	int depth;//深度，在树中的层数
	struct Node* father;//父节点
	int child_count;//字节点的数量
	struct Node* child[MAX_COUNT_OF_CHILD]; 
}Node;
#endif
Node* create_node();
void destroy_tree(Node* head);
void add(Node* father,int loc,Node* child);