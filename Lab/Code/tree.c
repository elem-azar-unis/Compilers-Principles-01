Node* create_node(Types type)
{
	Node* p=(Node*)malloc(sizeof(Node));
	if(p==NULL)
	{
		printf("Memory allocation error!\n");
		exit(0);
	}
	p->value_i=0;
	p->value_f=0.0;
	p->type=type;
	p->name[0]='\0';
	p->line=0;
	p->father=NULL;
	p->child_count=0;
	for(int i=0;i<MAX_COUNT_OF_CHILD;i++)
		p->child[i]=NULL;
	return p;
}
void add(Node* father,int loc,Node* child)
{
	father->child[loc]=child;
	child->father=father;
}
void destroy_tree(Node* head)
{
	if(head==NULL)
		return;
	for(int i=0;i<head->child_count;i++)
		destroy_tree(p->child[i]);
	free(head);
}