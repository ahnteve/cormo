// tslint:disable:max-classes-per-file

import { expect } from 'chai';
import * as cormo from '../..';

export default function(models: {
  connection: cormo.Connection | null,
}) {
  describe('issues', () => {
    it('reserved words', async () => {
      class Reference extends cormo.BaseModel {
        public group!: number;
      }
      Reference.index({ group: 1 });
      Reference.column('group', 'integer');
      const data = [
        { group: 1 },
        { group: 1 },
        { group: 2 },
        { group: 3 },
      ];
      const records = await Reference.createBulk(data);
      const record = await Reference.find(records[0].id).select('group');
      expect(record.id).to.eql(records[0].id);
      expect(record.group).to.eql(records[0].group);
      const count = await Reference.count({ group: 1 });
      expect(count).to.eql(2);
    });

    it('#5 invalid json value', async () => {
      class Test extends cormo.BaseModel {
        public name!: string;
      }
      Test.column('name', String);
      await Test.create({ name: 'croquis' });
      Test.column('object', { type: Object, required: true });
      Test.column('array', { type: [String], required: true });
      const records = await Test.where().lean(true);
      expect(records).to.eql([
        { id: records[0].id, name: 'croquis', object: null, array: null },
      ]);
    });
  });

  describe('query', () => {
    it('basic', async () => {
      class User extends cormo.BaseModel {
        public name!: string;
        public age!: number;
      }
      User.column('name', String);
      User.column('age', Number);
      const data = [
        { name: 'John Doe', age: 27 },
        { name: 'Bill Smith', age: 45 },
        { name: 'Alice Jackson', age: 27 },
        { name: 'Gina Baker', age: 32 },
        { name: 'Daniel Smith', age: 8 },
      ];
      const users = await User.createBulk(data);
      const rows = await models.connection!.adapter.query('SELECT * FROM users WHERE age=?', [27]);
      expect(rows).to.have.length(2);
      expect(rows[0]).to.eql({ id: users[0].id, name: users[0].name, age: users[0].age });
      expect(rows[1]).to.eql({ id: users[2].id, name: users[2].name, age: users[2].age });
    });
  });
}
