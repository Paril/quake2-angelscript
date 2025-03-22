void Use_Boss3(ASEntity &self, ASEntity &other, ASEntity @activator)
{
	gi_WriteByte(svc_t::temp_entity);
	gi_WriteByte(temp_event_t::BOSSTPORT);
	gi_WritePosition(self.e.s.origin);
	gi_multicast(self.e.s.origin, multicast_t::PHS, false);

	// just hide, don't kill ent so we can trigger it again
	self.e.svflags = svflags_t(self.e.svflags | svflags_t::NOCLIENT);
	self.e.solid = solid_t::NOT;
}

void Think_Boss3Stand(ASEntity &self)
{
	if (self.e.s.frame == boss32::frames::stand260)
		self.e.s.frame = boss32::frames::stand201;
	else
		self.e.s.frame++;
	self.nextthink = level.time + time_hz(10);
}

/*QUAKED monster_boss3_stand (1 .5 0) (-32 -32 0) (32 32 90)

Just stands and cycles in one place until targeted, then teleports away.
*/
void SP_monster_boss3_stand(ASEntity &self)
{
	if ( !M_AllowSpawn( self ) ) {
		G_FreeEdict( self );
		return;
	}

	self.movetype = movetype_t::STEP;
	self.e.solid = solid_t::BBOX;
	self.model = "models/monsters/boss3/rider/tris.md2";
	self.e.s.modelindex = gi_modelindex(self.model);
	self.e.s.frame = boss32::frames::stand201;

	gi_soundindex("misc/bigtele.wav");

	self.e.mins = { -32, -32, 0 };
	self.e.maxs = { 32, 32, 90 };

	@self.use = Use_Boss3;
	@self.think = Think_Boss3Stand;
	self.nextthink = level.time + FRAME_TIME_S;
	gi_linkentity(self.e);
}
