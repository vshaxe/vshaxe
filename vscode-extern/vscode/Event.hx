package vscode;

typedef Event<T> = (T->Dynamic)->?Dynamic->?Array<Disposable>->Disposable;
