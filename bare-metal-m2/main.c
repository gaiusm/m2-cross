
extern void M2MODULE_INIT ();
extern void M2MODULE_FINI ();


int
main ()
{
  M2MODULE_INIT ();
  M2MODULE_FINI ();
  return 0;
}
