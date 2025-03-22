//======================
// ROGUE
void misc_nuke_core_use(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	if ((self.e.svflags & svflags_t::NOCLIENT) != 0)
		self.e.svflags = svflags_t(self.e.svflags & ~svflags_t::NOCLIENT);
	else
		self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
}

/*QUAKED misc_nuke_core (1 0 0) (-16 -16 -16) (16 16 16)
toggles visible/not visible. starts visible.
*/
void SP_misc_nuke_core(ASEntity &ent)
{
	gi_setmodel(ent.e, "models/objects/core/tris.md2");
	gi_linkentity(ent.e);

	@ent.use = misc_nuke_core_use;
}
// ROGUE
//======================
