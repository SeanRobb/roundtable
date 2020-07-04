import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import VillagerOverview from './villagerOverview';

describe('<VillagerOverview />', () => {
  test('it should mount', () => {
    render(<VillagerOverview />);
    
    const VillagerOverview = screen.getByTestId('VillagerOverview');

    expect(VillagerOverview).toBeInTheDocument();
  });
});